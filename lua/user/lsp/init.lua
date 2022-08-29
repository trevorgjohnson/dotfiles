local lspconfig = require("lspconfig")

local mason_lspconfig = require("user.lsp.mason")
local handler = require("user.lsp.handlers")
handler.setup()

--------------- DYNAMIC SERVER SETUP ---------------

mason_lspconfig.setup_handlers({
  function(server_name)
    local setting_status, settings = pcall(require, "user/lsp/settings/" .. server_name)

    if not setting_status then
      settings = {}
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

-- RUST TOOLS --
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})
