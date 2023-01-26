local colorscheme = "catppuccin"

--[[ require('nightfox').setup({
  options = {
    transparent = true;
  }
}) ]]

vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha

require("catppuccin").setup({
  transparent_background = true;
  term_colors = true;
  integrations = {
    treesitter = true,
    treesitter_context = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
      },
    },
    lsp_trouble = true,
    cmp = true,
    gitsigns = true,
    telescope = true,
    nvimtree = true,
    neotree = {
      enabled = true,
      show_root = true,
      transparent_panel = false,
    },
    which_key = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
    },
    dashboard = true,
    markdown = true,
    ts_rainbow = true,
    symbols_outline = true,
  },
})

require 'colorizer'.setup()

vim.g.t_co = 256
vim.g.background = "dark"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

--[[ vim.g.material_style = 'deep ocean'
-- require('material').setup()
vim.cmd 'colorscheme material' ]]
