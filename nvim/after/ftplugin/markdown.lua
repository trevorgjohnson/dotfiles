vim.opt.wrap = true
vim.opt.linebreak = true

-- use treesitter folding
vim.o.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
