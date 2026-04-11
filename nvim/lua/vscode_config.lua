if not vim.g.vscode then
  return
end

if vim.fn.exists("*VSCodeNotify") ~= 1 then
  return
end

local map = vim.keymap.set

local function notify(action)
  return function()
    vim.fn.VSCodeNotify(action)
  end
end

map("n", "<C-s>", "<cmd>w<CR>", { silent = true })
map("x", "<leader>y", '"+y', { silent = true })
map("n", "<leader>yy", '"+yy', { silent = true })
map("n", "<leader>p", '"+p', { silent = true })
map("n", "<leader>nh", "<cmd>nohlsearch<CR>", { silent = true })

map({ "n", "x" }, "<leader>/", notify("editor.action.commentLine"), { silent = true })
map({ "n", "x" }, "<leader>z", notify("editor.action.commentLine"), { silent = true })

map("n", "Q", notify("editor.action.showHover"), { silent = true })
map("n", "[n", notify("editor.action.marker.prev"), { silent = true })
map("n", "]n", notify("editor.action.marker.next"), { silent = true })
map("n", "[d", notify("editor.action.marker.prev"), { silent = true })
map("n", "]d", notify("editor.action.marker.next"), { silent = true })

map("n", "gd", notify("editor.action.revealDefinition"), { silent = true })
map("n", "gD", notify("editor.action.goToTypeDefinition"), { silent = true })
map("n", "gy", notify("editor.action.goToTypeDefinition"), { silent = true })
map("n", "gr", notify("editor.action.goToReferences"), { silent = true })
map("n", "gi", notify("editor.action.goToImplementation"), { silent = true })
map("n", "<leader>rnm", notify("editor.action.rename"), { silent = true })
map("n", "<leader>ac", notify("editor.action.quickFix"), { silent = true })
map("n", "<leader>qf", notify("editor.action.quickFix"), { silent = true })
map("n", "<leader>rn", notify("editor.action.rename"), { silent = true })
map("n", "<leader>ca", notify("editor.action.quickFix"), { silent = true })

map("n", "<leader>f", notify("editor.action.formatDocument"), { silent = true })
map("x", "<leader>f", notify("editor.action.formatSelection"), { silent = true })
map("n", "<leader>fm", notify("editor.action.formatDocument"), { silent = true })

map("n", "<leader>n", notify("workbench.view.explorer"), { silent = true })
map("n", "<leader>e", notify("workbench.view.explorer"), { silent = true })
map("n", "<leader><leader>", notify("workbench.action.showCommands"), { silent = true })
map("n", "<leader>ff", notify("workbench.action.quickOpen"), { silent = true })
map("n", "<leader>fs", notify("workbench.action.quickOpen"), { silent = true })
map("n", "<leader>,", notify("workbench.action.showAllEditors"), { silent = true })
map("n", "<leader>ss", notify("workbench.action.gotoSymbol"), { silent = true })
map("n", "<leader>sS", notify("workbench.action.showAllSymbols"), { silent = true })
map("n", "<leader>fw", notify("workbench.action.findInFiles"), { silent = true })
map("n", "<leader>rg", notify("workbench.action.findInFiles"), { silent = true })
map("n", "H", notify("workbench.action.previousEditor"), { silent = true })
map("n", "L", notify("workbench.action.nextEditor"), { silent = true })
map("n", "<leader>bd", notify("workbench.action.closeActiveEditor"), { silent = true })
map("n", "<leader>bo", notify("workbench.action.closeOtherEditors"), { silent = true })
map("n", "<leader>xx", notify("workbench.actions.view.problems"), { silent = true })
map("n", "<leader>tt", notify("workbench.action.terminal.focus"), { silent = true })
