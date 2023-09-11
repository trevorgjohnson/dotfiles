local servers = {
  tsserver = {},
  tailwindcss = {},
  rust_analyzer = {},
  solidity_ls_nomicfoundation = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  }
}

-- Setup neovim lua configuration
require('neodev').setup()

local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- initalize handlers for lsp operations
local handler = require("user.lsp.handlers")
handler.setup()

-- Turn on lsp status information
require('fidget').setup({ window = { blend = 0 } })

mason_lspconfig.setup_handlers({
  function(server_name)
    if server_name == "rust_analyzer" then
      -- Use simrat39/rust-tools.nvim instead of rust_analyzer
      require("rust-tools").setup({
        server = {
          capabilities = handler.capabilities,
          on_attach = function(client, bufnr)
            handler.on_attach(client, bufnr)

            -- Set RT specific key maps
            vim.keymap.set('n', '<space>ka', require("rust-tools").hover_actions.hover_actions,
              { buffer = bufnr, desc = "RT: Hover [A]ctions" })
            vim.keymap.set('n', '<space>ca', require("rust-tools").code_action_group.code_action_group,
              { buffer = bufnr, desc = "RT: [C]ode [A]ctions" })

            -- automatically refresh codelens when entering/writing buffer
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWrite" },
              { callback = function() vim.lsp.codelens.refresh() end })
          end,
          settings = { ["rust-analyzer"] = { checkOnSave = { command = "clippy" } } }
        },
      })
      return
    end

    require("lspconfig")[server_name].setup {
      on_attach = handler.on_attach,
      capabilities = handler.capabilities,
      flags = handler.lsp_flags,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
})
