local map = vim.keymap.set

-- general mappings
map("n", "<C-s>", "<cmd> w <CR>")

-- nvimtree
map("n", "<C-n>", "<cmd> NvimTreeToggle <CR>")
map("n", "<C-h>", "<cmd> NvimTreeFocus <CR>")

-- telescope
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
map("n", "<leader>fw", "<cmd> Telescope live_grep <CR>")
map("n", "<leader>gt", "<cmd> Telescope git_status <CR>")
map("n", "<leader>t", "<cmd> Telescope <CR>")
map("n", "<leader>,", "<cmd> Telescope buffers <CR>")
map("n", "<leader>fs", "<cmd> Telescope current_buffer_fuzzy_find <CR>")
map("n", "gd", "<cmd> Telescope lsp_definitions <CR>" )
map("n", "gD", "<cmd> Telescope lsp_type_definitions <CR>")
map("n", "gr", "<cmd> Telescope lsp_references <CR>")
map("n", "gi", "<cmd> Telescope lsp_implementations <CR>")

-- comment.nvim
map("n", "<leader>/", "gcc", { remap = true })
map("v", "<leader>/", "gc", { remap = true })
map('n', "<leader>z", "gcc" , {remap = true})
map('v', "<leader>z", "gc" , {remap = true})

-- format
map("n", "<leader>fm", function()
    vim.lsp.buf.format()
end)

map('n', 'Q', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })

