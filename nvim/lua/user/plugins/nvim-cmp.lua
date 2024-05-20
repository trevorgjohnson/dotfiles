return {
  'hrsh7th/nvim-cmp',
  event = { "InsertEnter", "CmdlineEnter" },
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

    -- Formats the floating menu with nice nerd font icons
    'onsails/lspkind.nvim'
  },
  config = function()
    local cmp = require 'cmp'
    local lspkind = require('lspkind')
    local luasnip = require 'luasnip'
    luasnip.config.setup {}

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noinsert' },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = {
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<CR>"] = cmp.mapping.confirm { select = false, },
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      },
      formatting = {
        expandable_indicator = true,
        fields = { "kind", "abbr", "menu" },
        format = lspkind.cmp_format({
          mode = 'symbol',
          ellipsis_char = '...',
          show_labelDetails = true,
          before = function(_, vim_item)
            local MAX_MENU_WIDTH = math.floor(0.4 * vim.o.columns) -- 40% of total width
            local menu = vim_item.menu
            local truncated_menu = vim.fn.strcharpart(menu, 0, MAX_MENU_WIDTH)
            if truncated_menu ~= menu then
              vim_item.menu = truncated_menu .. '…'
            end
            return vim_item
          end
        })
      }
    }
  end
}
