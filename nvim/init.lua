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
require "user.treesitter"

-- Treelike file explorer
require("nvim-tree").setup()

-- Buffers (Vscode Tabs)
require "user.bufferline"

-- null ls
local null_ls = require("null-ls")
null_ls.setup({
  debug = false,
  sources = {
    null_ls.builtins.formatting.prettier.with({
      extra_filetypes = { "toml", "solidity" },
      disabled_filetypes = { 'json' }
    }),
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.diagnostics.solhint.with({
      extra_args = { "--formatter prettier", "--fix " }
    }),
  },
})

-- Floating Terminal
require "user.toggleterm"
