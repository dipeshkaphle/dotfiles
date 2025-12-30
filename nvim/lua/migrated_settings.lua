-- Migrated settings from .vimrc

-- General settings
vim.opt.encoding = "utf-8"
vim.opt.hidden = true
vim.opt.cmdheight = 2
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.syntax = "on"
vim.opt.shortmess:append("I")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.backspace = "indent,eol,start"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.visualbell = true
vim.opt.autoindent = true
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.clipboard:append("unnamed")
vim.opt.mouse:append("a")
vim.opt.winfixbuf = false


-- Filetype settings
vim.cmd("filetype plugin indent on")

-- Gruvbox Material theme settings
vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_palette = "original"
vim.g.gruvbox_material_disable_italic_comment = 0
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_visual = "reverse"


-- Highlighting
vim.api.nvim_set_hl(0, "Comment", { italic = true })
