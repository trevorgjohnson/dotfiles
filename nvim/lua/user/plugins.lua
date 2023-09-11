local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { -- Theme with nice pastel colors

    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        flavour = "mocha",
        term_colors = true,
      })

      vim.cmd.colorscheme 'catppuccin-mocha'
    end
  },

  { -- highlights color hexcodes with the hexcode color
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end
  },

  "nvim-lualine/lualine.nvim", -- Fancier statusline
  "tpope/vim-sleuth",          -- Detect tabstop and shiftwidth automatically
  "nvim-lua/popup.nvim",       -- An implementation of the Popup API from vim in Neovim

  -- Comment helpers (gcc/gb)
  { "numToStr/Comment.nvim",         opts = {} },

  { -- adds indentation guides
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    }
  },

  { -- Spawns a floating terminal that can be toggled
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      local mocha = require("catppuccin.palettes").get_palette "mocha"
      require("toggleterm").setup {
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = {
          border = "curved",
          winblend = 0,
        },
        persist_mode = true,
        highlights = {
          FloatBorder = {
            guifg = mocha.blue,
          },
        },
      }
    end
  },

  -- Git
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "lewis6991/gitsigns.nvim",

  { -- Nvim Tree
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {}
  },

  { -- Markdown Previewer
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  { -- Bufferline
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies =
    'nvim-tree/nvim-web-devicons',
    opts = {
      options = {
        offsets = { { filetype = "NvimTree", text = "File Explorer", padding = 1 } },
      },
    }
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',

      -- Additional tooling for rust development
      "simrat39/rust-tools.nvim",
    },
  },

  -- Huff
  "wuwe1/vim-huff",

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Adds additional completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",

      -- Adds a number of user-friendly snippets
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } }, -- Fuzzy Finder (files, lsp, etc)

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
}

require("lazy").setup(plugins)
