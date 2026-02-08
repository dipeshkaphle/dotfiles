require("nvim-treesitter").setup {}

local ensure_installed = { "lua", "vim", "vimdoc", "html", "css", "typescript", "javascript", "ocaml", "cpp", "rust" }
local installed = require("nvim-treesitter").get_installed()
local to_install = vim.tbl_filter(function(lang)
  return not vim.tbl_contains(installed, lang)
end, ensure_installed)
if #to_install > 0 then
  require("nvim-treesitter").install(to_install)
end
