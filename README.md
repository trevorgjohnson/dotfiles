# My NeoVim config

Modified from [Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch)

## Try out this config

Make sure to remove or move your current `nvim` directory

### MacOS/Linux

```
git clone git@github.com:trevorgjohnson/nvim-config.git ~/.config/nvim
```

### Windows

```
git clone https://github.com/trevorgjohnson/nvim-config.git ~/Appdata/Local/nvim
```

Then go to `lua/user/plugins.lua (line 6,9)` and `lua/user/dashboard.lua (line 208,211)` and comment/uncomment the relevant lines

_e.g._
```lua
-- uncomment below for MacOS/Linux
--[[ local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim" ]]

--uncomment below for Windows
local install_path = fn.stdpath('data') .. "\\site\\pack\\packer\\start\\packer.nvim"

```

---

Run `nvim` and wait for the plugins to be installed

Also run `npm i solidity-ls -g` for a working solidity lsp (_until the solc lsp works better_)

**NOTE** (You will notice treesitter pulling in a bunch of parsers the next time you open Neovim)

### Plugin List

- Packer - Plugin Manager
- popup - useful for popup windows
- plenary - useful for many other plugins
- autopairs - creates auto pairs of '(', '{', and '['
- colorizer - highlights color hexcodes with that specific color
- comment - for commenting ease
- nvim-ts-context-commentstring - use TS context to correctly commment (eg. jsx)
- impatient - speed up loading lua modules
- indent-blankline - adds indentatino guides
- alpha - adds dashboard on startup
- FixCursorHold - needed to fix lsp doc highlight
- which-key - displays popup with possible key bindings
- colorschemes
  - nightfox
  - material
  - roshnivim
- nvim-cmp - completion
- cmp-buffer - buffer completion
- cmp-path - path completion
- cmp-cmdline - cmdline completion
- cmp_luasnip - snippet completion
- cmp-nvim-lsp - LSP completion
- cmp-nvim-lua - extra lua completion
- luasnip - snippet engine
- friendly-snippets - useful snippets
- nvim-lspconfig - enable lsp
- mason.nvim - lsp installer
- mason-lspconfig - bridges mason with lspconfig
- null-ls - for formatters and linters
- rust-tools - for extra rust LSP helpers
- symbols-outline - tree view for lsp symbols
- telescope.nvim - fuzzy finder
- ripgrep - needed for telescope live grep
- treesitter - syntax highlighting
- nvim-ts-rainbow - bracket colorization
- gitsigns - vscode style git visualizations
- nvim-web-devicons - for adding icons (Nerd Font required)
- nvim-tree - file explorer
- bufferline - for buffers (kinda like tabs)
- vim-bbye - to close buffers
- lualine - statusline at the bottom
- toggleterm - easy use with floating terminal (also has lazy git support)
