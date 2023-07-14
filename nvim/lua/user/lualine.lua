local branch = {
  "branch",
  icons_enabled = true,
  icon = "",
}

local diff = {
  "diff",
  colored = false,
  symbols = { added = " ", modified = " ", removed = " " },
}


require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "auto",
    component_separators = { left = '|', right = '|' }, -- { left = '', right = ''},
    section_separators = { left = '', right = '' },
    globalstatus = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { branch, diff },
    lualine_c = { '' },
    lualine_x = { '' },
    lualine_y = { 'filetype' },
    lualine_z = { 'progress' }
  },
}
