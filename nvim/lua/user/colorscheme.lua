local colorscheme = "catppuccin"
vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha

require("catppuccin").setup({
  transparent_background = true;
  flavour = "mocha",
  term_colors = true;
  styles = {
    comments = { "italic" },
    keywords = { "bold" },
  },
  integrations = {
    treesitter = true,
    treesitter_context = true,
    cmp = true,
    gitsigns = true,
    telescope = true,
    nvimtree = true,
    markdown = true,
    neotree = {
      enabled = true,
      show_root = true,
      transparent_panel = true,
    },
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
