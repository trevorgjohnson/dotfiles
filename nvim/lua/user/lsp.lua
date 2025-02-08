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
  ts_ls = {
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
  },
  nil_ls = {}
}

-- describes all of the LSP capabilities of Neovim and any defaults described by 'blink.cmp'
---@type table|nil
local capabilities;
local function attach_server(server)
  -- grabs capabilities from local cache if not already set
  if not capabilities then
    capabilities = vim.tbl_deep_extend('force',
      vim.lsp.protocol.make_client_capabilities(),
      require('blink.cmp').get_lsp_capabilities())
  end
  server.capabilities = vim.tbl_deep_extend('force', server.capabilities or {}, capabilities)
  require('lspconfig')[server.name].setup(server)
end

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
      dependencies = { 'saghen/blink.cmp' },
      ensure_installed = vim.tbl_keys(servers or {}),
      automatic_installation = true,
      opts = {
        handlers = {
          function(server_name)
            -- attach server only if 'NIX_NEOVIM' flag isn't set
            if os.getenv("NIX_NEOVIM") ~= '1' then
              attach_server(vim.tbl_deep_extend('force', servers[server_name] or {}, { name = server_name }))
            end
          end,
          ['rust_analyzer'] = function() end, -- skip 'rust_analyzer' in favor of 'rustaceanvim'
        }
      },
    },

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

    -- Lua specific LSP tooling
    { 'folke/lazydev.nvim', opts = {}, ft = "lua", },
  },
  config = function()
    -- If we're currently on nix, attempt to set up all LSPs manually under 'servers' table
    if os.getenv("NIX_NEOVIM") == '1' then
      for server_name, server in pairs(servers) do
        -- skip 'rust_analyzer' in favor of 'rustaceanvim'
        if server_name ~= 'rust_analyzer' then
          attach_server(vim.tbl_deep_extend('force', server, { name = server_name }))
        end
      end
    end
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach-group', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func,
            { buffer = event.buf, desc = '[LSP]: ' .. desc })
        end

        map('gd', vim.lsp.buf.definition, "[g]o to the [d]efinition of a word")
        map('<leader>td', vim.lsp.buf.type_definition, "Display [t]ype [d]efinition of a word")
        map('<leader>rn', vim.lsp.buf.rename, "[r]e[n]ame all references of a word")
        map('<leader>ca', vim.lsp.buf.code_action,
          "Display and attempt available [c]ode [a]ctions on a word")

        local client = vim.lsp.get_client_by_id(event.data.client_id) -- get current lsp client
        if not client then return end                                 -- return early if client not found

        -- if client supports inlay hint, enable toggling using keymap
        if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[t]oggle inlay [h]ints')
        end

        -- if client supports formatting, format on keymap
        if client.supports_method('textDocument/formatting') then
          map('<leader>fm', vim.lsp.buf.format, "[f]or[m]at file")
        end
      end,
    })
  end
}
