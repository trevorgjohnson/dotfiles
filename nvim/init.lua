local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('user.keymaps')
require('user.options')
require('user.statusline')
require('user.terminal')

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
          FloatBorder = { fg = colors.mauve },
          BlinkCmpMenuBorder = { fg = colors.mauve },
          CurSearch = { bg = colors.mauve },
          DiagnosticVirtualTextError = { bg = colors.surface0 },
        }
      end
    },
    init = function() vim.cmd.colorscheme 'catppuccin-mocha' end
  },

  { -- file explorer
    'stevearc/oil.nvim',
    keys = { { "<leader>e", "<cmd>Oil --float<cr>", desc = "Toggle file explorer" } },
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
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { { "nvim-treesitter/nvim-treesitter-textobjects", } },
    config = function()
      local filetypes = { "rust", "solidity", "lua", "typescript", "markdown_inline", "diff" }
      require('nvim-treesitter').setup({
        ensure_installed = filetypes,
        auto_install = true,
        highlight = { enable = true, },
        indent = { enable = true },
        textobjects = {
          lsp_interop = {
            enable = true,
            border = 'none',
            floating_preview_opts = {},
            peek_definition_code = {
              ["<leader>k"] = "@function.outer",
              ["<leader>K"] = "@class.outer",
            },
          }
        }
      })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function() vim.treesitter.start() end,
      })
    end
  },

  { -- git decorations
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local nmap = function(keys, func, desc)
          vim.keymap.set('n', keys, func,
            { buffer = bufnr, desc = '[󰊢 ]: ' .. desc })
        end

        local gs = package.loaded.gitsigns
        nmap('[h', gs.next_hunk, "previous [h]unk")
        nmap(']h', gs.next_hunk, "next [h]unk")
        nmap('<leader>rh', gs.reset_hunk, "[r]eset [h]unk")
        nmap('<leader>ph', gs.preview_hunk, "[p]review [h]unk")
        nmap('<leader>sb', function() gs.blame_line { full = true } end, "[s]how [b]lame")
      end
    }
  },

  { -- completion engine
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    event = { "BufReadPre", "BufNewFile" },
    version = 'v1.*',
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
      appearance = { nerd_font_variant = 'mono' },
      cmdline = { enabled = false },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' }, },
      signature = { enabled = true, window = { border = 'rounded' } }
    }
  },

  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      { '<leader>fm',
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        { desc = '[f]or[m]at buffer' },
      }
    },
    opts = { formatters_by_ft = { typescript = { "prettier" }, rust = { "rustfmt" } } },
  },

  {
    "ibhagwan/fzf-lua",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = '[󰍉]: ' .. desc })
      end
      local fzf = require("fzf-lua")
      nmap('<leader>?', fzf.keymaps, 'find key mappings')
      nmap('<leader><space>', fzf.buffers, 'find open buffers')
      nmap('<leader>/', fzf.grep_curbuf, 'find in current buffer')
      nmap('<leader>ff', fzf.files, '[f]ind [f]ile')
      nmap('<leader>fo', fzf.lines, '[f]ind line in open buffers')
      nmap('<leader>fw', fzf.grep_cWORD, '[f]ind [w]ord')
      nmap('<leader>fg', fzf.live_grep, '[f]ind [w]ord')
      nmap('<leader>fs', fzf.git_status, '[f]ind git [s]tatus')
      nmap('<leader>fd', fzf.diagnostics_workspace, '[f]ind [d]iagnostics')
      nmap('grr', fzf.lsp_references, 'find LSP [r]efe[r]ences of a word')
      nmap('grd', fzf.lsp_definitions, 'find LSP [d]efinitions of a word')
      nmap('gtd', fzf.lsp_typedefs, 'find LSP [t]ype [d]efinitions of a word')
    end
  },

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
