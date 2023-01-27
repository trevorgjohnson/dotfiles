local M = {}

-- TODO: backfill this to template
M.setup = function()
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

  local config = {
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
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded"
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded"
  })
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
  end
  if client.name == "rust_analyzer" then
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
  end
  if client.name == "solidity" then
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
  end

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('K', vim.lsp.buf.hover, "Hover Documentation")
  nmap('<C-k>', vim.lsp.buf.signature_help, "Signature Help")

  nmap('gd', vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap('gD', vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap('gr', require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap('gi', vim.lsp.buf.implementation, "[G]oto [I]mplementation")

  nmap('<space>fm', vim.lsp.buf.format, "[F]or[m]at")
  nmap('<space>td', vim.lsp.buf.type_definition, "[T]ype [D]efinition")
  nmap('<space>ds', require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap('<space>rn', vim.lsp.buf.rename, "[R]e[n]ame")
  nmap('<space>ca', vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap('<space>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
  nmap('<space>wa', vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmap('<space>wr', vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmap('<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

return M
