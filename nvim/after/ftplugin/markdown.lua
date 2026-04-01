vim.opt.wrap = true
vim.opt.linebreak = true

-- nvim 0.12 built-in treesitter for markdown causes a `range` nil crash in the highlighter
vim.treesitter.stop()
vim.o.foldmethod = "manual"
