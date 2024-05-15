local servers = {
  tsserver = {},
  tailwindcss = {},
  rust_analyzer = {
    rust_analyzer = { settings = { checkOnSave = { command = "clippy" } } }
  },
  solidity_ls_nomicfoundation = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  }
}

local lsp_handler = {
  setup = function()
    local signs = { {
      name = "DiagnosticSignError",
      text = ""
    }, {
      name = "DiagnosticSignWarn",
      text = ""
    }, {
      name = "DiagnosticSignHint",
      text = ""
    }, {
      name = "DiagnosticSignInfo",
      text = ""
    } }

    for _, sign in ipairs(signs) do
      vim.fn.sign_define(sign.name, {
        texthl = sign.name,
        text = sign.text,
        numhl = ""
      })
    end

    vim.diagnostic.config({
      -- disable virtual text
      virtual_text = false,
      -- show signs
      signs = {
        active = signs
      },
      update_in_insert = true,
      underline = true,
      severity_sort = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = ""
      }
    })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded"
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = "rounded"
    })
  end,
  on_attach = function(_, bufnr)
    ---Sets `keys` to `func` and include description `desc` 
    ---@param keys string key(s) used to call `func`
    ---@param func function function called when `keys` are pressed
    ---@param desc string the description of the key binding
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('K', vim.lsp.buf.hover, "[LSP]: Display documentation of a word")
    nmap('<space>sk>', vim.lsp.buf.signature_help, "[LSP]: Displays [s]ignature help")

    nmap('gd', vim.lsp.buf.definition, "[LSP]: [g]o to the [d]efinition of a word")
    nmap('gD', vim.lsp.buf.declaration, "[LSP]: [g]o to the [D]eclaration of a word")
    nmap('gi', vim.lsp.buf.implementation, "[LSP]: [g]o to the [i]mplementation of a word")

    nmap('<space>fm', vim.lsp.buf.format, "[LSP]: [f]or[m]at file")
    nmap('<space>td', vim.lsp.buf.type_definition, "[LSP]: Display [t]ype [d]efinition of a word")
    nmap('<space>rn', vim.lsp.buf.rename, "[LSP]: [r]e[n]ame all references of a word")
    nmap('<space>ca', vim.lsp.buf.code_action, "[LSP]: Display and attempt available [c]ode [a]ctions on a word")
  end,
}

return {
  'neovim/nvim-lspconfig',
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    'folke/neodev.nvim',
    "hrsh7th/cmp-nvim-lsp",
    { "mrcjkb/rustaceanvim",                 version = "^4",                                        lazy = false, ft = "rust,toml", },
    { 'j-hui/fidget.nvim',                   tag = 'legacy',                                        opts = {} },
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "williamboman/mason.nvim",             dependencies = { "williamboman/mason-lspconfig.nvim" } },
  },
  config = function()
    require('neodev').setup()                           -- Setup neovim lua configuration
    require('fidget').setup({ window = { blend = 0 } }) -- Turn on lsp status information

    lsp_handler.setup();                                -- Set up handlers for LSP

    require('mason').setup()                            -- Set up LSP installer

    local mason_lspconfig = require("mason-lspconfig")
    mason_lspconfig.setup { ensure_installed = vim.tbl_keys(servers), }
    mason_lspconfig.setup_handlers({
      function(server_name)
        if server_name == "rust_analyzer" then
          ---@type RustaceanOpts
          vim.g.rustaceanvim = {
            server = {
              on_attach = function(client, bufnr)
                -- load default 'on_attach' capabilities
                lsp_handler.on_attach(client, bufnr)

                -- Use code actions through 'Rustaceanvim'
                vim.keymap.set('n', '<space>ca', function() vim.cmd.RustLsp('codeAction') end,
                  { silent = true, buffer = bufnr, desc = "[🦀-LSP]: Display and attempt available [c]ode [a]ctions on a word" })

                -- automatically refresh codelens when entering/writing buffer
                vim.api.nvim_create_autocmd({ "BufEnter", "BufWrite" },
                  { callback = function() vim.lsp.codelens.refresh() end })
              end,
              default_settings = { servers.rust_analyzer },
              cmd = function()
                local mason_registry = require('mason-registry')
                local ra_binary = mason_registry.is_installed('rust-analyzer')
                    -- This may need to be tweaked, depending on the operating system.
                    and mason_registry.get_package('rust-analyzer'):get_install_path() .. "/rust-analyzer"
                    or "rust-analyzer"
                return { ra_binary } -- You can add args to the list, such as '--log-file'
              end
            },
          }
        end

        require("lspconfig")[server_name].setup {
          on_attach = lsp_handler.on_attach,
          capabilities = lsp_handler.capabilities,
          flags = lsp_handler.lsp_flags,
          settings = servers[server_name],
          filetypes = (servers[server_name] or {}).filetypes,
        }
      end,
    })
  end
}
