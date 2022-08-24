local colorscheme = "carbonfox"

require('nightfox').setup({
  options = {
    transparent = true;
  }
})

require'colorizer'.setup()

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
