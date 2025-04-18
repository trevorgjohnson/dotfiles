-- Remap space as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

---Returns a table of default options for a keymapping along with the description of `desc`
---@param desc string the description to give the keymapping
---@return table M list of default options along with `desc`
local function opts_w_desc(desc)
  return {
    noremap = true,
    silent = true,
    desc = desc
  }
end

-- Set leader to <Nop> to prevent an possible clashing
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Open diagnostics in a loclist
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Move up/down using display lines. Good for soft-wrapped text
vim.keymap.set("n", "j", "gj", opts_w_desc("Move down one display line"))
vim.keymap.set("n", "k", "gk", opts_w_desc("Move up one display line"))

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts_w_desc("Move left one window"))
vim.keymap.set("n", "<C-j>", "<C-w>j", opts_w_desc("Move down one window"))
vim.keymap.set("n", "<C-k>", "<C-w>k", opts_w_desc("Move up one window"))
vim.keymap.set("n", "<C-l>", "<C-w>l", opts_w_desc("Move right one window"))

-- Vertical jumping keeps cursor in middle
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts_w_desc("Page down and keep cursor in the middle"))
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts_w_desc("Page up and keep cursor in the middle"))

-- Increment searching keeps cursor in middle ("zv" is for folding)
vim.keymap.set("n", "<n>", "nzzzv", opts_w_desc("Search down and keep cursor in the middle"))
vim.keymap.set("n", "<N>", "Nzzzv", opts_w_desc("Search up and keep cursor in the middle"))

vim.keymap.set("n", "<leader>C", ":bdelete!<cr>", opts_w_desc("[C]lose the current buffer"))

-- Resize with alt + vim keys
vim.keymap.set("n", "<M-j>", "<C-W>+", opts_w_desc("Increase window's vertical size"))
vim.keymap.set("n", "<M-k>", "<C-W>-", opts_w_desc("Decrease window's vertical size"))
vim.keymap.set("n", "<M-l>", "<c-w>5<", opts_w_desc("Increase window's horizontal size"))
vim.keymap.set("n", "<M-h>", "<c-w>5>", opts_w_desc("Decrease window's horizontal size"))

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts_w_desc("Switch to the next buffer"))
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts_w_desc("Switch to the previous buffer"))

-- Move text up and down
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts_w_desc("Move the current line up"))
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts_w_desc("Move the current line down"))

-- Move text up and down
vim.keymap.set("v", "<J>", ":m .+1<CR>==", opts_w_desc("Move the current line up"))
vim.keymap.set("v", "<K>", ":m .-2<CR>==", opts_w_desc("Move the current line down"))

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", opts_w_desc("Decrease indent and remains in visual mode"))
vim.keymap.set("v", ">", ">gv", opts_w_desc("Increase indent and stays in visual mode"))

-- map 'p' to paste over without putting into " registery
vim.keymap.set("v", "p", '"_dP', opts_w_desc("Paste without swapping the '\"' register"))

-- map 'x' to copy deleted text into blackhole registry
vim.keymap.set("", "x", '"_x', opts_w_desc("Delete selection to the blackhole registry"))

-- see ':help vim.diagnostic.*' for documentation on the below
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts_w_desc("Show [D]iagnostics"))
vim.keymap.set('n', '[d', vim.diagnostic.get_next, opts_w_desc("Goto previous [D]iagnostic"))
vim.keymap.set('n', ']d', vim.diagnostic.get_prev, opts_w_desc("Goto next [D]iagnostic"))

-- move through qflist
vim.keymap.set('n', '<M-n>', ':cnext<CR>')
vim.keymap.set('n', '<M-p>', ':cprev<CR>')

-- Remap 2x'Esc' to get out of terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

-- initialize terminal
local terminal = require('user.terminal')

-- Open terminal in vertical split to the right
vim.keymap.set("n", "<leader>tl", function() terminal.toggle { dir = "right" } end,
  opts_w_desc("Open terminal in vertical split on the right"))

-- Open terminal in horizontal split on the bottom
vim.keymap.set("n", "<leader>tj", function() terminal.toggle { dir = "below" } end,
  opts_w_desc("Open terminal in horizontal split on the bottom"))
