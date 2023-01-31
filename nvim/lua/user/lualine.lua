local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  sections = { "error", "warn" },
  symbols = { error = " ", warn = " " },
  colored = false,
  update_in_insert = false,
  always_visible = true,
}

local diff = {
  "diff",
  colored = false,
  symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
  --[[ cond = hide_in_width ]]
}

local branch = {
  "branch",
  icons_enabled = true,
  icon = "",
}

local mode = {
  "mode",
  fmt = function(str)
    return "" .. str .. ""
  end,
}

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "auto",
    component_separators = { left = '|', right = '|' }, -- { left = '', right = ''},
    -- section_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    globalstatus = true,
    -- disabled_filetypes = { "NvimTree", "Outline" },
    -- ignore_focus = {},
    -- always_divide_middle = true,
    -- refresh = { statusline = 1000, tabline = 1000, winbar = 1000 }
  },
  sections = {
    lualine_a = { mode },
    lualine_b = { branch, diagnostics },
    lualine_c = { diff },
    lualine_x = { '' },
    lualine_y = { 'filetype' },
    lualine_z = { 'progress' }
  },
  --[[
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { 'filename' },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
  ]]
}
