---Dedicated terminal toggles shared by split and floating presentations.
---
---Each terminal variant tracks its own buffer/window pair so repeated toggles
---reuse the same shell session instead of spawning a fresh terminal every time.
local M = {}

---@alias TerminalDirection "above" | "below" | "left" | "right"
---@alias TerminalLayout "float" | TerminalDirection
---@class TerminalState
---@field buf number Buffer currently backing the terminal session, or -1 if none exists yet.
---@field win number Window currently showing the terminal, or -1 when hidden.
---@field layout TerminalLayout|nil Layout currently displaying the terminal.

---Create an isolated state holder for a dedicated terminal instance.
---@return TerminalState
local function new_terminal_state()
  return { buf = -1, win = -1, layout = nil }
end

local split_term = new_terminal_state()
local float_term = new_terminal_state()

---Check whether a buffer is still valid and already hosts a terminal job.
---@param buf number
---@return boolean
local function is_terminal_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal"
end

---Return a valid scratch buffer that can be attached to a window immediately.
---
---The scratch buffer is just a placeholder until `:terminal` replaces it with a
---real terminal buffer in the newly opened window.
---@param buf number
---@return number
local function ensure_hidden_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    return buf
  end

  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  return buf
end

---Ensure the active window is backed by a terminal buffer and store it in state.
---
---`vim.cmd.terminal()` always operates on the current window, so callers must
---open the destination window first, then invoke this helper.
---@param state TerminalState
---@return number
local function ensure_terminal_buffer(state)
  if is_terminal_buffer(state.buf) then
    return state.buf
  end

  vim.cmd.terminal()
  state.buf = vim.api.nvim_get_current_buf()
  vim.bo[state.buf].bufhidden = "hide"
  return state.buf
end

---Check whether the tracked window is still visible in the active tab.
---@param win number
---@return boolean
local function is_window_in_current_tab(win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage()
end

---Toggle a dedicated terminal window.
---
---If the terminal window is already visible, hide it. Otherwise:
---1. Reuse or create a scratch buffer.
---2. Open the requested window style around that buffer.
---3. Lazily create the terminal job on first use.
---4. Enter insert mode so the shell is immediately interactive.
---@param state TerminalState
---@param layout TerminalLayout
---@param open_win fun(buf: number): number
local function show_terminal(state, layout, open_win)
  if is_window_in_current_tab(state.win) and state.layout == layout then
    vim.api.nvim_win_hide(state.win)
    state.win = -1
    state.layout = nil
    return
  end

  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_hide(state.win)
  end

  state.buf = ensure_hidden_buffer(state.buf)
  state.win = open_win(state.buf)
  state.layout = layout
  ensure_terminal_buffer(state)
  vim.api.nvim_win_set_buf(state.win, state.buf)

  vim.cmd.startinsert()
end

---Open the terminal in a regular split anchored in the requested direction.
---@param dir TerminalDirection
local function open_split(buf, dir)
  if dir == "right" then
    vim.cmd("botright vsplit")
  elseif dir == "left" then
    vim.cmd("topleft vsplit")
  elseif dir == "below" then
    vim.cmd("botright split")
  elseif dir == "above" then
    vim.cmd("topleft split")
  else
    error("Unsupported terminal split direction: " .. tostring(dir))
  end

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

---Open the terminal in a centered floating window sized to most of the editor.
---@param buf number
---@return number
local function open_float(buf)
  local columns = vim.o.columns
  local statusline = vim.o.laststatus > 0 and 1 or 0
  local tabline = 0
  if vim.o.showtabline == 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr "$" > 1) then
    tabline = 1
  end
  local lines = vim.o.lines - vim.o.cmdheight - statusline - tabline
  local width = math.max(80, math.floor(columns * 0.8))
  local height = math.max(20, math.floor(lines * 0.8))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((lines - height) / 2),
    col = math.floor((columns - width) / 2),
    width = width,
    height = height,
    border = "rounded",
    style = "minimal",
  })

  vim.wo[win].winhighlight = "Normal:Normal,NormalNC:Normal"
  return win
end

---Toggle the shared split terminal, preserving its shell session between opens.
---@param opts {dir: TerminalDirection}
M.toggle = function(opts)
  show_terminal(split_term, opts.dir, function(buf)
    return open_split(buf, opts.dir)
  end)
end

---Toggle the shared floating terminal, preserving its shell session between opens.
M.toggle_float = function()
  show_terminal(float_term, "float", open_float)
end

---Register keymaps for the dedicated split and floating terminals.
M.init = function()
  -- Open terminal in vertical split to the right
  vim.keymap.set("n", "<leader>tl", function() M.toggle { dir = "right" } end,
    { desc = "Open terminal in vertical split on the right" })

  -- Open terminal in horizontal split on the bottom
  vim.keymap.set("n", "<leader>tj", function() M.toggle { dir = "below" } end,
    { desc = "Open terminal in horizontal split on the bottom" })

  -- Toggle dedicated floating terminal
  vim.keymap.set({ "n", "t" }, "<C-\\>", function() M.toggle_float() end,
    { desc = "Toggle floating terminal" })
end

return M
