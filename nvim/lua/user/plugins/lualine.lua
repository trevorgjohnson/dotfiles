return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local branch = {
      "branch",
      icons_enabled = true,
      icon = "",
    }

    local diff = {
      "diff",
      colored = true,
      symbols = { added = " ", modified = " ", removed = " " },
    }

    local lazy_status = {
      require('lazy.status').updates,
      cond = require('lazy.status').has_updates,
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
        lualine_b = { branch },
        lualine_c = { diff },
        lualine_x = { lazy_status },
        lualine_y = { 'filetype' },
        lualine_z = { 'progress' }
      },
    }
  end
}
