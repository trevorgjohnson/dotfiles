local fn = vim.fn

-- Automatically install packer

-- uncomment below for MacOS/Linux
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

--uncomment below for Windows
--[[ local install_path = fn.stdpath("data") .. "\\site\\pack\\packer\\start\\packer.nvim" ]]

if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don"t error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

return packer.startup(function(use)
  -- Package manager
  use "wbthomason/packer.nvim"

  use { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Formatting and diagnosis
      "jose-elias-alvarez/null-ls.nvim",

      -- Useful status updates for LSP
      "j-hui/fidget.nvim",

      -- Additional lua configuration, makes nvim stuff amazing
      "folke/neodev.nvim",

      -- Additional tooling for rust development
      "simrat39/rust-tools.nvim",
      "mfussenegger/nvim-dap",
    },
  }

  use { -- Autocompletion
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",

      -- For parameter completion in functions
      "ray-x/lsp_signature.nvim",

      -- Snippets
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "saadparwaiz1/cmp_luasnip"
    },
  }

  use { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    run = function()
      pcall(require("nvim-treesitter.install").update { with_sync = true })
    end,
  }

  use { -- Additional text objects via treesitter
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
  }

  use "catppuccin/nvim" -- Theme with nice pastel colors
  use "nvim-lualine/lualine.nvim" -- Fancier statusline
  use "lukas-reineke/indent-blankline.nvim" -- adds indentation guides
  use "numToStr/Comment.nvim" -- Easily comment stuff
  use "tpope/vim-sleuth" -- Detect tabstop and shiftwidth automatically
  use "norcalli/nvim-colorizer.lua" -- highlights color hexcodes with the hexcode color
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim

  -- Fuzzy Finder (files, lsp, etc)
  use {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    requires = { "nvim-lua/plenary.nvim" }
  }

  -- Fuzzy Finder Algorithm which requires local dependencies to be built
  -- Only load if `make` is available
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    cond = vim.fn.executable "make" == 1
  }

  -- Git
  use "tpope/vim-fugitive"
  use "tpope/vim-rhubarb"
  use "lewis6991/gitsigns.nvim"

  -- Nvim Tree
  use { "kyazdani42/nvim-tree.lua", requires = { "kyazdani42/nvim-web-devicons" } }

  -- Bufferline
  use { "akinsho/bufferline.nvim", requires = { "moll/vim-bbye" } }

  -- Toggleterm
  use "akinsho/toggleterm.nvim"

  -- Markdown Previewer
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
