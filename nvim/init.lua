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

-- Comment helpers (gcc/gb)
require("Comment").setup()

-- Indenting
require("indent_blankline").setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}

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

-- Treelike file explorer
require("nvim-tree").setup()

-- set 'Huff' icon manually
require("nvim-web-devicons").set_icon { huff = {
  icon = "󰡘",
  color = "#4242c7",
  cterm_color = "65",
  name = "Huff"
} }

-- Buffers (Vscode Tabs)
require("bufferline").setup {
  options = {
    offsets = { { filetype = "NvimTree", text = "File Explorer", padding = 1 } },
  },
}
