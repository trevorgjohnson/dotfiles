-- scheduled to decrease startup time
vim.schedule(function()
  -- allows neovim to access the system clipboard
  vim.opt.clipboard = 'unnamedplus'
end)
vim.o.mouse = "a"                                      -- allow the mouse to be used in neovim

vim.o.cmdheight = 0                                    -- more space in the neovim command line for displaying messages
vim.cmd [[ autocmd RecordingEnter * set cmdheight=1 ]] -- when recording macros, set cmdheight to 1 to see "recording @..." message
vim.cmd [[ autocmd RecordingLeave * set cmdheight=0 ]] -- when done recording the macros, set cmdheight back to 0

-- force nvim to use nerd font
vim.g.have_nerd_font = true

-- set term colors
vim.g.t_co = 256
vim.g.background = "dark"

-- case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', ':nohlsearch<CR>')

-- highlight current line
vim.opt.cursorline = true
-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- display lines as one long line
vim.o.breakindent = true
vim.o.wrap = false

-- set term gui colors (most terminals support this)
vim.o.termguicolors = true

-- enable persistent undo
vim.o.undofile = true

-- keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Show relative line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- set min amount of lines on buffer borders
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- convert tabs to spaces and only use 2 spaces
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- shows all substitutions in a separate window
vim.o.inccommand = 'split'

--- open dialog window to confirm certain file/buffer operations
vim.o.confirm = true

-- adds rounded borders to hover docs
vim.o.winborder = 'rounded'

-- highlight briefly after yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank-group', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'CurSearch' })
  end,
})

-- Set buffer options for terminal buffer
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup('nvim-term-open', { clear = true }),
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
})

-- Set diagnostic options
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}
