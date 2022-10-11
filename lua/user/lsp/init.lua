local lspconfig = require("lspconfig")

local mason_lspconfig = require("user.lsp.mason")
local handler = require("user.lsp.handlers")
handler.setup()

-- RUST TOOLS --
local rt = require("rust-tools")

--------------- DYNAMIC SERVER SETUP ---------------

mason_lspconfig.setup_handlers({
  function(server_name)
    local setting_status, settings = pcall(require, "user/lsp/settings/" .. server_name)

    if not setting_status then
      settings = {}
    end

    if server_name == "solc" then
      return
    end

    if server_name == "rust_analyzer" then
      rt.setup({
        server = {
          on_attach = handler.on_attach,
          capabilities = handler.capabilities,
          flags = handler.lsp_flags,
          settings = settings,
        },
      })
      return
    end

    lspconfig[server_name].setup {
      on_attach = handler.on_attach,
      capabilities = handler.capabilities,
      flags = handler.lsp_flags,
      settings = settings,
    }

  end,
})

require("trouble").setup()
require("user.lsp.symbols-outline")
require("lsp_signature").setup()
