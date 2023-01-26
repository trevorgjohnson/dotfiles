local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = false,
  sources = {
    formatting.prettier.with({
      extra_filetypes = { "toml", "solidity" },
      disabled_filetypes = { 'json' }
    }),
    formatting.rustfmt,
    diagnostics.solhint.with({
      extra_args = { "--formatter prettier", "--fix " }
    }),
    --[[ diagnostics.eslint, ]]
  },
})
