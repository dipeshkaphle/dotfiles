-- Migrated keymaps from .vimrc

local map = vim.keymap.set

-- General mappings
map("n", "Q", "<Nop>")

-- Insert mode mappings
map("i", "<C-k>", "<Up>")
map("i", "<C-j>", "<Down>")
map("i", "<C-l>", "<Right>")
map("i", "<C-h>", "<Left>")
map("i", "<C-s>", "<Esc>:w<CR>i")
map("i", "<C-w>", "<C-o>W")
map("i", "<C-b>", "<C-o><C-Left>")
map("i", "<C-f>", "<C-o>^")
map("i", "<C-e>", "<C-o>$")
map("i", "<C-t>", "<C-o>O")
map("i", "<C-d>", "<C-o>o")

-- Normal mode mappings
map("n", "<S-j>", "<C-e>")
map("n", "<S-k>", "<C-y>")


-- Split resizing
map("n", "<C-w>>", "10<C-w>>")
map("n", "<C-w><", "10<C-w><")
