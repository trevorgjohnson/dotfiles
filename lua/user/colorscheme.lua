local colorscheme = "carbonfox"

require('nightfox').setup({
  options = {
    transparent = false;
  }
})

require'colorizer'.setup()

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

--[[ vim.g.material_style = 'deep ocean'
-- require('material').setup()
vim.cmd 'colorscheme material' ]]
