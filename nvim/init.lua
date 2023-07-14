-- Plugins
require "user.plugins"

-- Options
require "user.options"

-- Keymaps (:Telescope keymaps)
require "user.keymaps"

-- Themes
require "user.colorscheme"

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
    numbers = "none",
    close_command = "bdelete! %d",       -- can be a string | function, see "Mouse actions"
    right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d",    -- can be a string | function, see "Mouse actions"
    offsets = { { filetype = "NvimTree", text = "File Explorer", padding = 1 } },
  },
  highlights = require("catppuccin.groups.integrations.bufferline").get()
}

-- Floating Terminal
require("toggleterm").setup {
  open_mapping = [[<c-\>]],
  direction = "float",
  float_opts = {
    border = "curved", -- 'single' | 'double' | 'shadow' | 'curved'
  },
}
