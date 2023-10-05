local opts = {
  noremap = true,
  silent = true
}

-- Remap space as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set leader to <Nop> to prevent an possible clashing
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Vertical jumping keeps cursor in middle
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Increment searching keeps cursor in middle ("zv" is for folding)
vim.keymap.set("n", "<n>", "nzzzv", opts)
vim.keymap.set("n", "<N>", "Nzzzv", opts)

vim.keymap.set("n", "<leader>C", ":bdelete!<cr>", opts)

-- Resize with arrows
vim.keymap.set("n", "<A-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<A-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<A-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<A-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
--
-- Move text up and down
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Move text up and down
vim.keymap.set("v", "<J>", ":m .+1<CR>==", opts)
vim.keymap.set("v", "<K>", ":m .-2<CR>==", opts)

-- map 'p' to paste over without putting into " registery
vim.keymap.set("v", "p", '"_dP', opts)

-- map 'x' to copy deleted text into blackhole registry
vim.keymap.set("", "x", '"_x', { desc = "Delete to blackhole registry" })

-- write and quit currently open buffer
vim.keymap.set("", "<leader>q", ':wq<CR>', { desc = "[W]rite and [Q]uit buffer" })

-- write and quit all currently open buffers
vim.keymap.set("", "<leader>Q", ':wqa<CR>', { desc = "[W]rite and [Q]uit [A]ll buffers" })

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show [D]iagnostics" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Goto previous [D]iagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Goto next [D]iagnostic" })
