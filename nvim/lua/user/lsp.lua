-- common inlay hints used for typescript and javascript
local inlayHints = {
  includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
  includeInlayParameterNameHintsWhenArgumentMatchesName = true,
  includeInlayVariableTypeHints = true,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

--- @type  {string: vim.lsp.Config }[]
local servers = {
  ts_ls = {
    settings = {
      typescript = { inlayHints = inlayHints },
      javascript = { inlayHints = inlayHints },
    },
  },
  rust_analyzer = {
    settings = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      checkOnSave = {
        allFeatures = true,
        command = "clippy",
        extraArgs = { "--no-deps" },
      },
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
    }
  },
  solidity_ls_nomicfoundation = {},
  typos_lsp = { init_options = { diagnosticSeverity = "Warning" } },
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }
  },
  nil_ls = {}
}

return {
  'neovim/nvim-lspconfig',
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- LSP status updates
    { 'j-hui/fidget.nvim',  opts = { notification = { window = { winblend = 0 } } } },

    { -- Rust specific LSP tooling
      "mrcjkb/rustaceanvim",
      version = "^5",
      lazy = false, -- already lazy
      ft = "rust,toml",
      config = function()
        vim.g.rustaceanvim = {
          server = {
            default_settings = { ['rust_analyzer'] = servers['rust_analyzer'] },
            cmd = function()
              local bin_loc = 'rust-analyzer' -- default to global install
              local mason_registry = require('mason-registry')
              if mason_registry.is_installed('rust-analyzer') then
                local ra = mason_registry.get_package('rust-analyzer')
                local ra_filename = ra:get_receipt():get().links.bin
                    ['rust-analyzer']
                bin_loc = ('%s/%s'):format(ra:get_install_path(),
                  ra_filename or 'rust-analyzer')
              end
              return { bin_loc }
            end,

          },
        }
      end
    },

    { 'folke/lazydev.nvim', opts = {}, ft = "lua", }, -- Lua specific LSP tooling
    'saghen/blink.cmp', -- Allows extra capabilities provided by blink.cmp
  },
  config = function()
    -- Attempt to attach
    for s_name, s_opts in pairs(servers) do
      -- skip 'rust_analyzer' in favor of 'rustaceanvim'
      if s_name ~= 'rust_analyzer' then
        s_opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, s_opts.capabilities or {})
        -- set the configuration of the lsp
        vim.lsp.config(s_name, s_opts or {})
        -- enabble the server
        vim.lsp.enable(s_name)
      end
    end
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach-group', { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id) -- get current lsp client
        if not client then return end                                 -- return early if client not found

        -- if client supports inlay hint, enable toggling using keymap
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          vim.keymap.set('n', '<leader>th',
            function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end,
            { buffer = event.buf, desc = '[LSP]: [t]oggle inlay [h]ints' })
        end
      end,
    })
  end
}
