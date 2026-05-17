require('user.options')
require('user.keymaps')
require('user.statusline')
require('user.context')

require('user.terminal').init()

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'catppuccin/nvim' }
require('catppuccin').setup {
  flavour = "mocha",
  transparent_background = true,
  ---@class CtpColors<T>: {rosewater: T, flamingo: T, pink: T, mauve: T, red: T, maroon: T, peach: T, yellow: T, green: T, teal: T, sky: T, sapphire: T, blue: T, lavender: T, text: T, subtext1: T, subtext0: T, overlay2: T, overlay1: T, overlay0: T, surface2: T, surface1: T, surface0: T, base: T, mantle: T, crust: T, none: T }
  ---@param colors CtpColors<string>
  custom_highlights = function(colors)
    return {
      NormalFloat = { bg = colors.mantle },
      FloatBorder = { fg = colors.mauve, bg = colors.none },
      -- BlinkCmpMenuBorder = { fg = colors.mauve },
      CurSearch = { bg = colors.mauve },
      ContextYank = { bg = colors.blue, fg = colors.base },
      OpencodeAskPending = { bg = colors.peach, fg = colors.base },
      IncSearch = { bg = colors.mauve },
      FzfLuaSearch = { bg = colors.mauve, fg = colors.base },
      DiagnosticVirtualTextError = { bg = colors.surface0 },
      StatuslineFile = { fg = colors.surface1 },
      StatuslineGit = { bg = colors.mauve, fg = colors.base },
      StatuslineModeNormal = { bg = colors.blue, fg = colors.base },
      StatuslineModeVisual = { bg = colors.red, fg = colors.base },
      StatuslineModeInsert = { bg = colors.green, fg = colors.base },
      StatuslineModeOther = { bg = colors.yellow, fg = colors.base },
    }
  end
}
vim.cmd.colorscheme 'catppuccin-mocha'

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

vim.pack.add {{ src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' }}
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
    vim.keymap.set('n', '<leader>sb', function() gs.blame_line { full = true } end, { buffer = bufnr, desc = "[s]how [b]lame" })
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
vim.keymap.set('n', '<leader>fn', function() fzf.live_grep({ cwd = vim.env.VAULT, winopts = { title="Grep Notes" }}) end, { desc = '[󰍉]: [f]ind in [n]otes' })
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
