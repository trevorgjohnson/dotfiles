-- current buffer number
local bufnr = vim.api.nvim_get_current_buf();

-- map <leader>ra to rustaceanvim's code action
vim.keymap.set('n', '<space>ra', function() vim.cmd.RustLsp('codeAction') end,
  { desc = "[🦀-LSP]: Display and attempt available [r]ust code [a]ctions on a word", silent = true, buffer = bufnr })

-- automatically refresh lsp codelens on buffer enter/write
vim.api.nvim_create_autocmd({ "BufEnter", "BufWrite" }, { callback = function() vim.lsp.codelens.refresh({ bufnr }) end })

-- override built-in hover keymap with rustaceanvim's hover actions
vim.keymap.set("n", "K", function() vim.cmd.RustLsp({ 'hover', 'actions' }) end, { silent = true, buffer = bufnr })
