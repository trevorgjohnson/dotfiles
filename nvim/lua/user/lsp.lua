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
}

return {
  'neovim/nvim-lspconfig',
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Attempt to configure and enable each server listed in `servers`
    for s_name, s_opts in pairs(servers) do
      -- set the configuration of the lsp
      vim.lsp.config(s_name, s_opts or {})
      -- Skip servers that fail validation (eg. missing executables)
      pcall(vim.lsp.enable, s_name)
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

        -- if client supports codelens, auto-refresh on enter and save
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens, event.buf) then
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
            buffer = event.buf,
            callback = vim.lsp.codelens.refresh,
          })
        end
      end,
    })
  end
}
