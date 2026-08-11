require('user.options')
require('user.keymaps')
require('user.statusline')
require('user.context')

require('user.terminal').init()

vim.cmd.colorscheme 'catppuccin'
local mocha = { base = "#1e1e2e", mantle = "#181825", surface0 = "#313244", surface1 = "#45475a", mauve = "#cba6f7", blue =
"#89b4fa", red = "#f38ba8", green = "#a6e3a1", yellow = "#f9e2af", sky = "#89dceb", teal = "#94e2d5", text = "#cdd6f4", }
vim.api.nvim_set_hl(0, "Normal", { bg = "none" }) -- transparent background
for level, color in pairs({ Error = mocha.red, Warn = mocha.yellow, Info = mocha.sky, Hint = mocha.teal, Ok = mocha.green }) do
  vim.api.nvim_set_hl(0, "Diagnostic" .. level, { fg = color })
  vim.api.nvim_set_hl(0, "DiagnosticSign" .. level, { fg = color })
  vim.api.nvim_set_hl(0, "DiagnosticFloating" .. level, { fg = color })
  vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. level, { sp = color, underline = true })
  vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. level, { fg = color, bg = mocha.surface0 })
end
vim.api.nvim_set_hl(0, "NormalFloat", { bg = mocha.mantle })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = mocha.mauve })
vim.api.nvim_set_hl(0, "StatusLine", { fg = mocha.text, bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = mocha.surface1, bg = "none" })
vim.api.nvim_set_hl(0, "StatuslineFile", { fg = mocha.text, bg = "none" })
vim.api.nvim_set_hl(0, "FzfLuaSearch", { fg = mocha.base, bg = mocha.mauve })
vim.api.nvim_set_hl(0, "StatuslineGit", { fg = mocha.base, bg = mocha.mauve })
vim.api.nvim_set_hl(0, "ContextYank", { fg = mocha.base, bg = mocha.blue })
vim.api.nvim_set_hl(0, "StatuslineModeNormal", { fg = mocha.base, bg = mocha.blue })
vim.api.nvim_set_hl(0, "StatuslineModeVisual", { fg = mocha.base, bg = mocha.red })
vim.api.nvim_set_hl(0, "StatuslineModeInsert", { fg = mocha.base, bg = mocha.green })
vim.api.nvim_set_hl(0, "StatuslineModeOther", { fg = mocha.base, bg = mocha.yellow })

local function gh(repo) return 'https://github.com/' .. repo end

if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons' } end

vim.pack.add { gh 'stevearc/oil.nvim' }
require('oil').setup {
  keymaps = {
    ["<C-l>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
    ["<C-j>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
    ["<C-R>"] = { "actions.refresh" },
    ["<leader>e"] = "actions.close",
  }
}
vim.keymap.set('n', '<leader>e', "<cmd>Oil --float<cr>", { desc = 'Toggle file explorer' })

vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }
local ts = require('nvim-treesitter')
ts.install({ 'solidity', 'typescript', 'markdown', 'markdown_inline' })
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then return end
    -- if a parser is available but not installed, install it
    if not vim.tbl_contains(ts.get_installed('parsers'), language) then
      if vim.tbl_contains(ts.get_available(), language) then ts.install(language) end
    end
    -- If the language parser was added properly, start it up on the attached buffer
    if vim.treesitter.language.add(language) then vim.treesitter.start(args.buf, language) end
  end,
})

vim.pack.add { gh "lewis6991/gitsigns.nvim" }
require('gitsigns').setup {
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = "previous [h]unk" })
    vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = "next [h]unk" })
    vim.keymap.set('n', '<leader>rh', gs.reset_hunk, { buffer = bufnr, desc = "[r]eset [h]unk" })
    vim.keymap.set('n', '<leader>ph', gs.preview_hunk, { buffer = bufnr, desc = "[p]review [h]unk" })
    vim.keymap.set('n', '<leader>sb', function() gs.blame_line { full = true } end,
      { buffer = bufnr, desc = "[s]how [b]lame" })
  end
}

vim.pack.add { gh "stevearc/conform.nvim" }
require('conform').setup {
  formatters_by_ft = { typescript = { "prettier" }, rust = { "rustfmt" } }
}
vim.keymap.set('n', '<leader>fm',
  function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
  { desc = '[f]or[m]at buffer' })

vim.pack.add { gh "ibhagwan/fzf-lua" }
local fzf = require("fzf-lua")
-- Set ctrl-q to send all search results to the qfixlist (similar to telescope)
fzf.setup { keymap = { fzf = { ["ctrl-q"] = "select-all+accept", } } }
-- hijack's vim.ui.select so fzflua (minimal float near cursor) is always used instead
fzf.register_ui_select()
vim.keymap.set('n', '<leader>?', fzf.keymaps, { desc = '[󰍉]: find key mappings' })
vim.keymap.set('n', '<leader><space>', fzf.buffers, { desc = '[󰍉]: find open buffers' })
vim.keymap.set('n', '<leader>/', fzf.grep_curbuf, { desc = '[󰍉]: find in current buffer' })
vim.keymap.set('n', '<leader>ff', fzf.files, { desc = '[󰍉]: [f]ind [f]ile' })
vim.keymap.set('n', '<leader>fo', fzf.lines, { desc = '[󰍉]:[f]ind line in open buffers' })
vim.keymap.set('n', '<leader>fw', fzf.grep_cword, { desc = '[󰍉]: [f]ind [w]ord' })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = '[󰍉]: [f]ind [w]ord' })
vim.keymap.set('n', '<leader>fs', fzf.git_status, { desc = '[󰍉]: [f]ind git [s]tatus' })
vim.keymap.set('n', '<leader>fd', fzf.diagnostics_workspace, { desc = '[󰍉]: [f]ind [d]iagnostics' })
vim.keymap.set('n', '<leader>fn',
  function() fzf.live_grep({ cwd = vim.env.VAULT, winopts = { title = "Grep Notes" } }) end,
  { desc = '[󰍉]: [f]ind in [n]otes' })
vim.keymap.set('n', 'grr', fzf.lsp_references, { desc = '[󰍉]: find LSP [r]efe[r]ences of a word' })
vim.keymap.set('n', 'grd', fzf.lsp_definitions, { desc = '[󰍉]: find LSP [d]efinitions of a word' })
vim.keymap.set('n', 'gtd', fzf.lsp_typedefs, { desc = '[󰍉]: find LSP [t]ype [d]efinitions of a word' })

vim.pack.add { gh 'neovim/nvim-lspconfig' }
local servers = {
  ts_ls = {},
  rust_analyzer = {
    settings = {
      cargo = { allFeatures = true, loadOutDirsFromCheck = true, runBuildScripts = true },
      checkOnSave = { allFeatures = true, command = "clippy", extraArgs = { "--no-deps" } },
      procMacro = { enable = true },
    }
  },
  solidity_ls_nomicfoundation = {},
  typos_lsp = { init_options = { diagnosticSeverity = "Warning" } },
  lua_ls = { settings = { Lua = { telemetry = { enable = false }, }, } },
}
for s_name, s_opts in pairs(servers) do
  vim.lsp.config(s_name, s_opts or {})
  pcall(vim.lsp.enable, s_name)
end
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach-group', { clear = true }),
  -- Enable native lsp completion
  callback = function(ev) vim.lsp.completion.enable(true, ev.data.client_id, ev.buf) end
})
