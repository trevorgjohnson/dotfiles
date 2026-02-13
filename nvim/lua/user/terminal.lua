local M = {} -- initialize terminal module

---comment Current buffer and window state of the terminal
local term_state = { buf = -1, win = -1 }

---comment Creates new scratch buffer (if needed) and split window
---@param opts {buf: number, dir: "above" | "below" | "left" | "right"}
local create_buf_and_win = function(opts)
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf                             -- use saved buffer
  else
    buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
  end
  local win = vim.api.nvim_open_win(buf, true, { split = opts.dir })
  return { buf = buf, win = win }
end


---comment Toggles a split terminal
---@param opts {dir: "above" | "below" | "left" | "right"}
M.toggle = function(opts)
  if not vim.api.nvim_win_is_valid(term_state.win) then
    term_state = create_buf_and_win({ buf = term_state.buf, dir = opts.dir })
    if vim.bo[term_state.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(term_state.win)
  end
end

-- Initalizes the terminal module by setting the proper keymaps
M.init = function()
  -- Open terminal in vertical split to the right
  vim.keymap.set("n", "<leader>tl", function() M.toggle { dir = "right" } end,
    { desc = "Open terminal in vertical split on the right" })

  -- Open terminal in horizontal split on the bottom
  vim.keymap.set("n", "<leader>tj", function() M.toggle { dir = "below" } end,
    { desc = "Open terminal in horizontal split on the bottom" })
end

return M
