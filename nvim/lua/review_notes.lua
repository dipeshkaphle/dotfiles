local M = {}

M.state = {
  current_file = nil,
  comments_shown = false,
  ns_id = vim.api.nvim_create_namespace("review_notes_comments"),
  review_dir = nil, -- Optional override
}

function M.setup(opts)
  opts = opts or {}
  if opts.dir then
    M.state.review_dir = vim.fn.expand(opts.dir)
  end
end

local function script_path()
  -- Assume scripts/review_notes.py is relative to the dotfiles root or somewhere in PATH
  -- Ideally, we find the script relative to this lua file or assume a fixed location.
  -- For this user, it's in ~/dotfiles/scripts/review_notes.py based on previous `ls`.
  -- Let's try to find it dynamically or hardcode for now.
  local root = vim.fs.root(0, { ".git", ".pi" }) or vim.fn.expand("~")
  local candidates = {
    vim.fs.joinpath(root, "scripts", "review_notes.py"),
    vim.fs.joinpath(vim.fn.expand("~"), "dotfiles", "scripts", "review_notes.py"),
    vim.fs.joinpath(vim.fn.expand("~"), ".config", "scripts", "review_notes.py"), -- fallback
  }
  
  for _, p in ipairs(candidates) do
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
  return "review_notes.py" -- Hope it's in PATH
end

local function exec_json(cmd)
  -- Inject --dir if set
  if M.state.review_dir then
    table.insert(cmd, 3, "--dir")
    table.insert(cmd, 4, M.state.review_dir)
  end
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Review Notes Error: " .. output, vim.log.levels.ERROR)
    return nil
  end
  local ok, res = pcall(vim.json.decode, output)
  if not ok then
    vim.notify("Review Notes JSON Error: " .. output, vim.log.levels.ERROR)
    return nil
  end
  return res
end

local function list_review_files()
  local script = script_path()
  return exec_json({ "python3", script, "list" }) or {}
end

local function create_review_file(name)
  local script = script_path()
  local cmd = { "python3", script, "create", name }
  -- Must inject dir here too if configured
  if M.state.review_dir then
    table.insert(cmd, 3, "--dir")
    table.insert(cmd, 4, M.state.review_dir)
  end
  local output = vim.fn.system(cmd)
  local ok, res = pcall(vim.json.decode, output)
  return ok and res and res.path
end

local function append_snippet(target, rel_path, s, e, comment, lang, content)
  local script = script_path()
  local cmd = {
    "python3", script, "add",
    target, rel_path, tostring(s), tostring(e),
    comment, lang
  }
  
  if M.state.review_dir then
    table.insert(cmd, 3, "--dir")
    table.insert(cmd, 4, M.state.review_dir)
  end

  -- Pass content via stdin
  local job = vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("Added snippet to " .. vim.fn.fnamemodify(target, ":t"), vim.log.levels.INFO)
      else
        vim.notify("Failed to add snippet", vim.log.levels.ERROR)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
  
  vim.fn.chansend(job, content)
  vim.fn.chanclose(job, "stdin")
end

local function parse_comments(target)
  local script = script_path()
  local cmd = { "python3", script, "parse", target }
  if M.state.review_dir then
    table.insert(cmd, 3, "--dir")
    table.insert(cmd, 4, M.state.review_dir)
  end
  local output = vim.fn.system(cmd)
  local ok, res = pcall(vim.json.decode, output)
  return (ok and res) or {}
end

-- ... (Keep helpers: project_root, filename_only, relpath_from_root, ui_select, ui_input, pick_or_create_review_file)
local function project_root()
  local root = vim.fs.root(0, { ".git", ".pi" })
  return root or vim.fn.getcwd()
end

local function filename_only(p)
  return vim.fn.fnamemodify(p, ":t")
end

local function relpath_from_root(abs)
  local root = vim.fs.normalize(project_root())
  local full = vim.fs.normalize(abs)
  local prefix = root .. "/"
  if full == root then
    return vim.fn.fnamemodify(full, ":t")
  end
  if full:sub(1, #prefix) == prefix then
    return full:sub(#prefix + 1)
  end
  return vim.fn.fnamemodify(full, ":~:.")
end

local function ui_select(prompt, items, cb)
  -- Prefer Telescope picker when available
  local has_telescope, pickers = pcall(require, "telescope.pickers")
  if has_telescope then
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers
      .new({}, {
        prompt_title = prompt,
        finder = finders.new_table({ results = items }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(bufnr, _map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(bufnr)
            cb(selection and selection[1] or nil)
          end)
          return true
        end,
      })
      :find()
    return
  end

  if vim.ui and vim.ui.select then
    vim.ui.select(items, { prompt = prompt }, cb)
    return
  end

  local opts = { prompt }
  for i, item in ipairs(items) do
    table.insert(opts, string.format("%d. %s", i, item))
  end
  local idx = vim.fn.inputlist(opts)
  if idx <= 0 or idx > #items then
    cb(nil)
  else
    cb(items[idx])
  end
end

local function ui_input(prompt, cb)
  if vim.ui and vim.ui.input then
    vim.ui.input({ prompt = prompt }, cb)
    return
  end
  local v = vim.fn.input(prompt)
  if v == nil or v == "" then
    cb(nil)
  else
    cb(v)
  end
end

local function get_review_dir()
  return M.state.review_dir or vim.fn.expand("~/.review-notes")
end

local function pick_or_create_review_file(cb)
  local files = list_review_files()
  local items = {}

  if M.state.current_file then
    table.insert(items, "Use current: " .. filename_only(M.state.current_file))
  end

  for _, f in ipairs(files) do
    table.insert(items, filename_only(f))
  end

  table.insert(items, "+ Create new review file")

  ui_select("Select review target", items, function(choice)
    if not choice then
      cb(nil)
      return
    end

    if choice:match("^Use current:") and M.state.current_file then
      cb(M.state.current_file)
      return
    end

    if choice == "+ Create new review file" then
      ui_input("New review name (without .md): ", function(name)
        if not name or vim.trim(name) == "" then
          cb(nil)
          return
        end
        local path = create_review_file(name)
        if path then
          M.state.current_file = path
          cb(path)
        end
      end)
      return
    end

    local full = vim.fs.joinpath(get_review_dir(), choice)
    M.state.current_file = full
    cb(full)
  end)
end

local function get_visual_range_lines()
  local s = vim.fn.getpos("'<")[2]
  local e = vim.fn.getpos("'>")[2]
  if s > 0 and e > 0 then
    if s > e then s, e = e, s end
    return s, e
  end
  local l = vim.api.nvim_win_get_cursor(0)[1]
  return l, l
end

local function sanitize_text(s)
  if not s then return "" end
  return s:gsub("%z", "")
end

function M.select_review_file()
  pick_or_create_review_file(function(target)
    if target then
      vim.notify("Current review: " .. filename_only(target), vim.log.levels.INFO)
    end
  end)
end

function M.open_current_review()
  if not M.state.current_file then
    M.select_review_file()
    return
  end
  vim.cmd("edit " .. vim.fn.fnameescape(M.state.current_file))
end

function M.add_comment_from_selection()
  local buf = vim.api.nvim_get_current_buf()
  local abs = vim.api.nvim_buf_get_name(buf)
  if abs == "" then return end

  local start_l, end_l = get_visual_range_lines()
  local lines = vim.api.nvim_buf_get_lines(buf, start_l - 1, end_l, false)
  local selected = sanitize_text(table.concat(lines, "\n"))
  local rel = relpath_from_root(abs)
  local ext = vim.fn.fnamemodify(abs, ":e")

  if not M.state.current_file then
     M.select_review_file()
     if not M.state.current_file then return end
  end

  ui_input("Comment: ", function(comment)
    if not comment then return end
    append_snippet(M.state.current_file, rel, start_l, end_l, comment, ext, selected)
  end)
end

function M.toggle_comments()
  if M.state.comments_shown then
    vim.api.nvim_buf_clear_namespace(0, M.state.ns_id, 0, -1)
    M.state.comments_shown = false
    vim.notify("Review comments hidden", vim.log.levels.INFO)
    return
  end

  if not M.state.current_file then
    M.select_review_file()
    if not M.state.current_file then return end
  end
  
  local comments = parse_comments(M.state.current_file)
  local buf = vim.api.nvim_get_current_buf()
  local abs = vim.api.nvim_buf_get_name(buf)
  local rel = relpath_from_root(abs)
  local count = 0
  
  for _, item in ipairs(comments) do
    if abs:sub(-#item.file) == item.file then
       local start_l = item.start_line - 1
       local end_l = item.end_line -- 1-based inclusive -> 0-based exclusive for range
       
       if start_l >= 0 then
         -- 1. Highlight the code range
         vim.api.nvim_buf_set_extmark(buf, M.state.ns_id, start_l, 0, {
           end_line = end_l,
           hl_group = "Visual",
           strict = false
         })

         -- 2. Add comment text below the snippet (at the last line)
         -- Wrap long comments using virtual lines
         local max_width = 80
         local prefix = "   "
         local indent = "    "
         local current_line = prefix
         local lines = {}
         
         for word in item.comment:gmatch("%S+") do
           if #current_line + #word + 1 > max_width then
             table.insert(lines, {{current_line, "Comment"}})
             current_line = indent .. word
           else
             if #current_line == #prefix or #current_line == #indent then
                current_line = current_line .. word
             else
                current_line = current_line .. " " .. word
             end
           end
         end
         table.insert(lines, {{current_line, "Comment"}})
         
         -- Attach virtual lines to the last line of the snippet
         vim.api.nvim_buf_set_extmark(buf, M.state.ns_id, end_l - 1, 0, {
           virt_lines = lines,
           virt_lines_above = false,
           strict = false
         })
         
         count = count + 1
       end
    end
  end
  
  M.state.comments_shown = true
  vim.notify(string.format("Showing %d comments from %s", count, filename_only(M.state.current_file)), vim.log.levels.INFO)
end

return M
