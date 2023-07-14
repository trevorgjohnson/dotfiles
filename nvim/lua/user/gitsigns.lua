require("gitsigns").setup {
  current_line_blame_opts = {
    delay = 250,
  },
  current_line_blame_formatter_opts = { relative_time = true },
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  yadm = {
    enable = false,
  },

  -- MAPPINGS
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local nmap = function(keys, func, desc)
      if desc then
        desc = 'GIT: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    nmap('[h', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, "Previous [H]unk")

    nmap(']h', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, "Next [H]unk")

    nmap('<leader>ph', gs.preview_hunk, "[P]review [H]unk")
    nmap('<leader>sb', function() gs.blame_line { full = true } end, "[S]how [B]lame")
    nmap('<leader>tb', gs.toggle_current_line_blame, "[T]oggle [B]lame")
    nmap('<leader>sd', gs.diffthis, "[S]how [D]iff")
  end
}
