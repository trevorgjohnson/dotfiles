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

local servers = {
  tsserver = {
    settings = {
      typescript = { inlayHints = inlayHints },
      javascript = { inlayHints = inlayHints },
    },
  },
  tailwindcss = {},
  rust_analyzer = {
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
  },
  solidity_ls_nomicfoundation = {},
  lua_ls = {
    Lua = {
      settings = { Lua = { completion = { callSnippet = 'Replace' } } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  }
}

-- describes all of the LSP capabilities of Neovim and any defaults described by 'cmp_nvim_lsp'
---@type table|nil
local capabilities;

return {
  'neovim/nvim-lspconfig',
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- LSP status updates
    { 'j-hui/fidget.nvim',       opts = { notification = { window = { winblend = 0 } } } },

    -- LSP installer
    { "williamboman/mason.nvim", opts = {} },

    { -- Links LSP installer to lspconfig
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "hrsh7th/cmp-nvim-lsp" },
      ensure_installed = vim.tbl_keys(servers or {}),
      automatic_installation = true,
      opts = {
        handlers = {
          function(server_name)
            -- grabs capabilities from local cache if not already set
            if not capabilities then
              capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(),
                require('cmp_nvim_lsp').default_capabilities())
            end

            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
          ['rust_analyzer'] = function() end, -- skip 'rust_analyzer' in favor of 'rustaceanvim'
        }
      }
    },

    -- Rust specific LSP tooling
    {
      "mrcjkb/rustaceanvim",
      version = "^4",
      lazy = false,
      ft = "rust,toml",
      opts = { server = { default_settings = { ['rust_analyzer'] = servers['rust_analyzer'] }, }, },
      config = function(_, opts)
        vim.g.rustaceanvim = vim.tbl_deep_extend("force", {
          cmd = function()
            local mason_registry = require('mason-registry')
            local ra_binary = mason_registry.is_installed('rust-analyzer')
                and mason_registry.get_package('rust-analyzer'):get_install_path() .. "/rust-analyzer"
                or "rust-analyzer"
            return { ra_binary }
          end
        }, opts or {})
      end,
    },

    -- Lua specific LSP tooling
    { 'folke/lazydev.nvim', opts = {}, ft = "lua", },
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach-group', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func,
            { buffer = event.buf, desc = '[LSP]: ' .. desc })
        end

        map('gd', vim.lsp.buf.definition, "[g]o to the [d]efinition of a word")
        -- map('<leader>fm', vim.lsp.buf.format, "[f]or[m]at file")
        map('<leader>td', vim.lsp.buf.type_definition, "Display [t]ype [d]efinition of a word")
        map('<leader>rn', vim.lsp.buf.rename, "[r]e[n]ame all references of a word")
        map('<leader>ca', vim.lsp.buf.code_action, "Display and attempt available [c]ode [a]ctions on a word")

        -- enables inlay hints in your code if the language server supports them
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(_))
          end, '[t]oggle inlay [h]ints')
        end
      end,
    })
  end
}
