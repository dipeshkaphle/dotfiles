local M = {}

M.state = {
  current_file = nil,
}

local function project_root()
  local root = vim.fs.root(0, { ".git", ".pi" })
  return root or vim.fn.getcwd()
end

local function reviews_dir()
  local dir = vim.fs.joinpath(vim.fn.expand("~/.pi"), "reviews")
  vim.fn.mkdir(dir, "p")
  return dir
end

local function list_review_files()
  local dir = reviews_dir()
  local files = vim.fn.globpath(dir, "*.md", false, true)
  table.sort(files)
  return files
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
        name = vim.trim(name):gsub("%s+", "-")
        local full = vim.fs.joinpath(reviews_dir(), name .. ".md")
        if vim.fn.filereadable(full) == 0 then
          local header = {
            "# Review Notes: " .. name,
            "",
            "Created: " .. os.date("%Y-%m-%d %H:%M:%S"),
            "",
          }
          vim.fn.writefile(header, full)
        end
        M.state.current_file = full
        cb(full)
      end)
      return
    end

    local full = vim.fs.joinpath(reviews_dir(), choice)
    M.state.current_file = full
    cb(full)
  end)
end

local function get_visual_range_lines()
  -- Visual marks are more reliable than checking current mode in mapped callbacks.
  local s = vim.fn.getpos("'<")[2]
  local e = vim.fn.getpos("'>")[2]

  if s > 0 and e > 0 then
    if s > e then
      s, e = e, s
    end
    return s, e
  end

  -- Fallback: current cursor line
  local l = vim.api.nvim_win_get_cursor(0)[1]
  return l, l
end

local function sanitize_text(s)
  if not s then
    return ""
  end
  -- Strip embedded NUL bytes that can appear from certain visual/block selections.
  s = s:gsub("%z", "")
  return s
end

local function with_current_review(cb)
  if M.state.current_file then
    cb(M.state.current_file)
    return
  end
  pick_or_create_review_file(function(target)
    cb(target)
  end)
end

local function add_selection()
  local buf = vim.api.nvim_get_current_buf()
  local abs = vim.api.nvim_buf_get_name(buf)
  if abs == "" then
    vim.notify("Buffer has no file path", vim.log.levels.WARN)
    return
  end

  local start_l, end_l = get_visual_range_lines()
  local lines = vim.api.nvim_buf_get_lines(buf, start_l - 1, end_l, false)
  local selected = sanitize_text(table.concat(lines, "\n"))
  local rel = relpath_from_root(abs)
  local ext = vim.fn.fnamemodify(abs, ":e")

  with_current_review(function(target)
    if not target then
      return
    end

    vim.ui.input({ prompt = "Comment: " }, function(comment)
      if comment == nil then
        return
      end
      comment = sanitize_text(comment)

      local block = {
        "## " .. rel .. " (lines " .. start_l .. "-" .. end_l .. ")",
        "Comment: " .. (comment ~= "" and comment or "(none)"),
        "",
        "```" .. (ext ~= "" and ext or "text"),
        selected,
        "```",
        "",
      }

      vim.fn.writefile(block, target, "a")
      vim.notify("Added snippet to " .. filename_only(target), vim.log.levels.INFO)
    end)
  end)
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
  add_selection()
end

function M.prefill_for_pi()
  local target = M.state.current_file
  if not target or vim.fn.filereadable(target) == 0 then
    vim.notify("No current review file selected", vim.log.levels.WARN)
    return
  end

  local content = vim.fn.readfile(target)
  local prompt = {
    "I collected these snippets from the codebase. Please answer based on them first, and tell me if extra files are needed.",
    "",
  }
  vim.list_extend(prompt, content)
  vim.list_extend(prompt, { "", "My question:" })

  vim.fn.setreg("+", table.concat(prompt, "\n"))
  vim.notify("Compiled prompt copied to clipboard (+ register)", vim.log.levels.INFO)
end

return M
