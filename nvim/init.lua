local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('user.keymaps')
require('user.options')

require("lazy").setup({
  { -- cozy colorscheme
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      default_integrations = true,
      integrations = { blink_cmp = true },
      transparent_background = true,
      flavour = "mocha",
      term_colors = true,
      ---@class CtpColors<T>: {rosewater: T, flamingo: T, pink: T, mauve: T, red: T, maroon: T, peach: T, yellow: T, green: T, teal: T, sky: T, sapphire: T, blue: T, lavender: T, text: T, subtext1: T, subtext0: T, overlay2: T, overlay1: T, overlay0: T, surface2: T, surface1: T, surface0: T, base: T, mantle: T, crust: T, none: T }
      ---@param colors CtpColors<string>
      custom_highlights = function(colors)
        return {
          DiagnosticVirtualTextError = { bg = colors.surface0 },
          CurSearch = { bg = colors.mauve }
        }
      end
    },
    init = function() vim.cmd.colorscheme 'catppuccin-mocha' end
  },

  -- highlights todo coments
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, event = { "VimEnter" }, opts = { signs = true }, },

  { -- opens markdown in browser fully rendered
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  { -- file explorer
    'stevearc/oil.nvim',
    keys = {
      { "<leader>e", "<cmd>Oil --float<cr>", desc = "Toggle file explorer" }
    },
    opts = {
      keymaps = {
        ["<C-l>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
        ["<C-j>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
        ["<C-R>"] = { "actions.refresh" },
        ["<leader>e"] = "actions.close",
      }
    },
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
  },

  { -- semantic highlighting
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPre", "BufNewFile" },
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { "rust", "solidity", "lua", "typescript", "markdown_inline", "diff" },
      auto_install = true,
      highlight = { enable = true, },
      indent = { enable = true },
    },
  },

  { -- git decorations
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame_opts = { delay = 250, },
      current_line_blame_formatter = " <author>, <author_time:%R> - <summary> ",
      preview_config = { border = "rounded", },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local nmap = function(keys, func, desc)
          vim.keymap.set('n', keys, func,
            { buffer = bufnr, desc = '[󰊢 ]: ' .. desc })
        end

        -- Navigation
        nmap('[h', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, "Previous [H]unk")

        nmap(']h', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, "Next [H]unk")

        nmap('<leader>rh', gs.reset_hunk, "[r]eset [h]unk")
        nmap('<leader>ph', gs.preview_hunk, "[p]review [h]unk")
        nmap('<leader>sb', function() gs.blame_line { full = true } end, "[s]how [b]lame")
        nmap('<leader>tb', gs.toggle_current_line_blame, "[t]oggle [b]lame")
        nmap('<leader>sd', gs.diffthis, "[s]how [d]iff")
      end
    }
  },

  { -- status and buffer line
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'catppuccin',
        component_separators = { left = '', right = '' }, -- { left = '', right = ''},
        section_separators = { left = '', right = '' },
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { { 'buffers', symbols = { alternate_file = '' }, use_mode_colors = true } },
        lualine_c = {},
        lualine_x = { { require('lazy.status').updates, cond = require('lazy.status').has_updates }, 'diff' },
        lualine_y = { 'filetype' },
        lualine_z = { {
          'branch',
          icon = "",
          fmt = function(str)
            local MAX_BRANCH_WIDTH = math.floor(0.08 * vim.o.columns) -- 8% of total width
            if #str > MAX_BRANCH_WIDTH then
              str = vim.fn.strcharpart(str, 0, MAX_BRANCH_WIDTH) .. '…'
            end
            return str
          end
        } }
      },
    }
  },

  { -- completion engine
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    event = { "BufReadPre", "BufNewFile" },
    version = 'v0.*',
    opts = {
      keymap = {
        preset = 'default', -- see ':help ins-completion'
        ['<C-u>'] = { 'scroll_documentation_up' },
        ['<C-d>'] = { 'scroll_documentation_down' },
      },
      completion = {
        menu = { border = 'rounded', },
        documentation = { auto_show = true, auto_show_delay_ms = 100, window = { border = 'rounded' } },
      },
      appearance = { nerd_font_variant = 'normal' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        cmdline = {}, -- Disable cmdline completions
      },
      signature = { enabled = true, window = { border = 'rounded' } }
    }
  },

  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      { '<leader>fm',
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        { desc = '[f]or[m]at buffer' },
      }
    },
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        rust = { "rustfmt" }
      }
    },
  },

  { import = 'user.telescope' },
  { import = 'user.lsp' },
}, {
  install = { colorscheme = { 'catppuccin-mocha' } },
  ui = { border = "rounded" },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = { notify = false }

})
