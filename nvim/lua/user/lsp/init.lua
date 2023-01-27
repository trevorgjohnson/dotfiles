local servers = {
  tsserver = {},
  tailwindcss = {},
  jsonls = {},
  sumneko_lua = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- Setup mason so it can manage external tooling
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- initalize handlers for lsp operations
local handler = require("user.lsp.handlers")
handler.setup()

-- Turn on lsp status information
require('fidget').setup()

-- Turn on function param signature help
require("lsp_signature").setup()

mason_lspconfig.setup_handlers({
  function(server_name)
    if server_name == "rust_analyzer" then
      require("rust-tools").setup({
        server = {
          capabilities = handler.capabilities,
          on_attach = handler.on_attach,
        },
      })
      return
    end

    require("lspconfig")[server_name].setup {
      on_attach = handler.on_attach,
      capabilities = handler.capabilities,
      flags = handler.lsp_flags,
      settings = servers[server_name],
    }
  end,
})
