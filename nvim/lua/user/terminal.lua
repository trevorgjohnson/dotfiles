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
---When `cmd` is given the job is started via `jobstart` (used for managed
---processes like opencode that need their own command and cleanup hooks).
---Otherwise falls back to `vim.cmd.terminal()` for a plain interactive shell.
---`vim.cmd.terminal()` always operates on the current window, so callers must
---open the destination window first, then invoke this helper.
---@param state TerminalState
---@param cmd? string Command to run; omit for a plain shell.
---@param on_create? fun(win: number) Called with the window before the job starts.
---@return number
local function ensure_terminal_buffer(state, cmd, on_create)
  if is_terminal_buffer(state.buf) then
    return state.buf
  end

  if cmd then
    if on_create then on_create(state.win) end
    vim.fn.jobstart(cmd, {
      term = true,
      on_exit = function()
        state.buf = -1
        state.win = -1
        state.layout = nil
      end,
    })
  else
    vim.cmd.terminal()
  end

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
---@param cmd? string Optional command to run; omit for a plain shell.
---@param on_create? fun(win: number) Called with the window before the job starts.
local function show_terminal(state, layout, open_win, cmd, on_create)
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
  ensure_terminal_buffer(state, cmd, on_create)
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
  local lines = vim.o.lines - vim.o.cmdheight
  local width = math.max(80, math.floor(columns * 0.9))
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
---@param cmd? string Optional command to run; omit for a plain shell.
---@param on_create? fun(win: number) Called with the window before the job starts.
M.toggle_float = function(cmd, on_create)
  show_terminal(float_term, "float", open_float, cmd, on_create)
end

---Start the floating terminal's process in the background without opening a window.
---
---Opens a temporary off-screen window just long enough to attach the terminal job,
---then immediately hides it. Subsequent calls to `toggle_float` will reuse the
---already-running session.
---@param cmd string Command to run.
---@param on_create? fun(win: number) Called with the window before the job starts.
M.start_float_hidden = function(cmd, on_create)
  if is_terminal_buffer(float_term.buf) then return end

  float_term.buf = ensure_hidden_buffer(float_term.buf)

  -- Briefly open an off-screen window so `jobstart { term = true }` has a
  -- window context, then hide it immediately after the job is attached.
  local tmp_win = vim.api.nvim_open_win(float_term.buf, false, {
    relative = "editor",
    row = 0,
    col = 0,
    width = 1,
    height = 1,
    style = "minimal",
    noautocmd = true,
  })
  if on_create then on_create(tmp_win) end
  local saved_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(tmp_win)
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      float_term.buf = -1
      float_term.win = -1
      float_term.layout = nil
    end,
  })
  float_term.buf = vim.api.nvim_get_current_buf()
  vim.bo[float_term.buf].bufhidden = "hide"
  vim.api.nvim_win_hide(tmp_win)
  vim.api.nvim_set_current_win(saved_win)
end

---Stop the floating terminal, killing its job and cleaning up state.
M.stop_float = function()
  local job_id = vim.api.nvim_buf_is_valid(float_term.buf)
      and vim.b[float_term.buf].terminal_job_id
  if job_id then
    vim.fn.jobstop(job_id)
  end
  if vim.api.nvim_win_is_valid(float_term.win) then
    vim.api.nvim_win_close(float_term.win, true)
  end
  if vim.api.nvim_buf_is_valid(float_term.buf) then
    vim.api.nvim_buf_delete(float_term.buf, { force = true })
  end
  float_term.buf = -1
  float_term.win = -1
  float_term.layout = nil
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
