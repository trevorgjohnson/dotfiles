-- Remap space as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Plugins
require "user.plugins"

-- Options
require "user.options"

-- Keymaps (:Telescope keymaps)
require "user.keymaps"

-- Statusline
require "user.lualine"

-- Git signs
require "user.gitsigns"

--Telescope
require "user.telescope"

-- LSP
require "user.lsp"

-- Completion
require "user.cmp"

-- Treesitter
require("nvim-treesitter.configs").setup { highlight = { enable = true } }
