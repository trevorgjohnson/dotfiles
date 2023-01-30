require("gitsigns").setup {
  signs = {
    add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
    change = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    delete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    topdelete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    changedelete = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter_opts = {
    relative_time = false,
  },
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
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

    -- nmap('<leader>hS', gs.stage_buffer)
    -- nmap('<leader>hu', gs.undo_stage_hunk)
    -- nmap('<leader>hR', gs.reset_buffer)
    -- nmap('<leader>hD', function() gs.diffthis('~') end)
    -- nmap('<leader>td', gs.toggle_deleted)

    -- vim.keymap.set({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    -- vim.keymap.set({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    -- vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

  end
}
