-- current buffer number
local bufnr = vim.api.nvim_get_current_buf();

vim.keymap.set('n', '<space>ra', function() vim.cmd.RustLsp('codeAction') end,
        {
                desc = "[🦀-LSP]: Display and attempt available [r]ust code [a]ctions on a word",
                silent = true,
                buffer = bufnr
        })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWrite" },
        { callback = function() vim.lsp.codelens.refresh({ bufnr }) end })
