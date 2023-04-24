local servers = {
  tsserver = {},
  tailwindcss = {},
  jsonls = {},
  --[[ sumneko_lua = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  }, ]]
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

local configs = require 'lspconfig.configs'
if not configs.nomic_solidity then
  configs.nomic_solidity = {
    default_config = {
      cmd = { 'nomicfoundation-solidity-language-server', '--stdio' },
      filetypes = { 'solidity' },
      root_dir = require("lspconfig.util").find_git_ancestor,
      require("lspconfig.util").root_pattern "foundry.toml",
      single_file_support = true,
      settings = {},
    },
  }
end

mason_lspconfig.setup_handlers({
  function(server_name)
    if server_name == "rust_analyzer" then
      -- Use simrat39/rust-tools.nvim instead of rust_analyzer
      require("rust-tools").setup({
        tools = {
          autoSetHints = true,
          runnables = { use_telescope = true },
          hover_actions = { auto_focus = true },
          inlay_hints = {
            auto = true,
            show_parameter_hints = true,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
          },
        },
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

    if server_name == "solidity" then
      require("lspconfig").nomic_solidity.setup({
        on_attach = handler.on_attach,
        capabilities = handler.capabilities,
        flags = handler.lsp_flags,
        -- settings = servers[server_name],
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
