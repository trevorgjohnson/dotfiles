vim.o.clipboard = "unnamedplus"        -- allows neovim to access the system clipboard
vim.o.completeopt = "menuone,noselect" -- mostly just for cmp
vim.o.mouse = "a"                      -- allow the mouse to be used in neovim

vim.o.cmdheight = 0 -- more space in the neovim command line for displaying messages
vim.cmd [[ autocmd RecordingEnter * set cmdheight=1 ]] -- when recording macros, set cmdheight to 1 to see "recording @..." message
vim.cmd [[ autocmd RecordingLeave * set cmdheight=0 ]] -- when done recording the macros, set cmdheight back to 0

-- case insensitive searching UNLESS /C or capital in search
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- highlight current line
vim.wo.cursorline = true

-- make indenting smarter again
vim.o.smartindent = true
vim.o.breakindent = true

-- display lines as one long line
vim.o.wrap = false

-- set term gui colors (most terminals support this)
vim.o.termguicolors = true

-- enable persistent undo
vim.o.undofile = true

-- faster completion (4000ms default)
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Show relative line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- set min amount of lines on buffer borders
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- convert tabs to spaces and only use 2 spaces
vim.o.expandtab = true
vim.o.tabstop = 2
vim.g.shiftwidth = 2

vim.o.foldlevel = 20
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-- Highlight briefly after yanking
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
