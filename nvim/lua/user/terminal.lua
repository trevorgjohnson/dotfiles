---Dedicated terminal toggles shared by split and floating presentations.
---
---Each terminal variant tracks its own buffer/window pair so repeated toggles
---reuse the same shell session instead of spawning a fresh terminal every time.

---@alias TerminalDirection "above" | "below" | "left" | "right"
---@alias TerminalLayout "float" | TerminalDirection

---@class Terminal
---@field buf number Buffer currently backing the terminal session, or -1 if none exists yet.
---@field win number Window currently showing the terminal, or -1 when hidden.
---@field layout TerminalLayout|nil Layout currently displaying the terminal.
---@field private _default_layout TerminalLayout|nil Default layout for toggle().
---@field private _default_open_win (fun(buf: number): number)|nil Default window opener for toggle().
local Terminal = {}
Terminal.__index = Terminal

---Create a new terminal instance.
---@param default_layout? TerminalLayout Fixed layout used when toggle() is called without an override.
---@param default_open_win? fun(buf: number): number Fixed window opener used when toggle() is called without an override.
---@return Terminal
function Terminal.new(default_layout, default_open_win)
  return setmetatable({
    buf = -1, win = -1, layout = nil,
    _default_layout = default_layout,
    _default_open_win = default_open_win,
  }, Terminal)
end

-- ---------------------------------------------------------------------------
-- Private helpers
-- ---------------------------------------------------------------------------

---Check whether a buffer is still valid and already hosts a terminal job.
---@param buf number
---@return boolean
local function is_terminal_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal"
end

---Return a valid scratch buffer suitable for attaching to a window before the
---terminal job is created.
---@param buf number
---@return number
local function ensure_hidden_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) then return buf end
  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  return buf
end

---Check whether a window is still visible in the active tab.
---@param win number
---@return boolean
local function is_window_in_current_tab(win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage()
end

---Start a terminal job in the current window context and store the resulting buffer.
---@param cmd string Command to run.
---@param on_create? fun(win: number) Called with the current window before the job starts.
function Terminal:_start_job(cmd, on_create)
  if on_create then on_create(vim.api.nvim_get_current_win()) end
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function()
      self.buf = -1
      self.win = -1
      self.layout = nil
    end,
  })
  self.buf = vim.api.nvim_get_current_buf()
  vim.bo[self.buf].bufhidden = "hide"
end

---Ensure the current window is backed by a running terminal buffer.
---
---When `cmd` is given the job is started via `jobstart` (used for managed
---processes like opencode that need their own command and cleanup hooks).
---Otherwise falls back to `vim.cmd.terminal()` for a plain interactive shell.
---@param cmd? string Command to run; omit for a plain shell.
---@param on_create? fun(win: number) Called with the window before the job starts.
function Terminal:_ensure_terminal(cmd, on_create)
  if is_terminal_buffer(self.buf) then return end

  if cmd then
    self:_start_job(cmd, on_create)
  else
    vim.cmd.terminal()
    self.buf = vim.api.nvim_get_current_buf()
    vim.bo[self.buf].bufhidden = "hide"
  end
end

-- ---------------------------------------------------------------------------
-- Window openers (stateless — only create and return a window)
-- ---------------------------------------------------------------------------

---Open a split window anchored in the requested direction.
---@param buf number
---@param dir TerminalDirection
---@return number
local function open_split(buf, dir)
  local cmds = {
    right = "botright vsplit",
    left  = "topleft vsplit",
    below = "botright split",
    above = "topleft split",
  }
  assert(cmds[dir], "Unsupported terminal split direction: " .. tostring(dir))
  vim.cmd(cmds[dir])

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

---Open a centered floating window sized to most of the editor.
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

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

---Toggle the terminal window.
---
---If the terminal is already visible with the same layout, hide it.
---Otherwise open (or reopen) in the requested layout, lazily creating the
---terminal job on first use.
---@param opts? table Optional overrides: layout, open_win, cmd, on_create.
function Terminal:toggle(opts)
  opts = opts or {}
  local layout = opts.layout or self._default_layout
  local open_win = opts.open_win or self._default_open_win

  if is_window_in_current_tab(self.win) and self.layout == layout then
    vim.api.nvim_win_hide(self.win)
    self.win = -1
    self.layout = nil
    return
  end

  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_hide(self.win)
  end

  self.buf = ensure_hidden_buffer(self.buf)
  self.win = open_win(self.buf)
  self.layout = layout
  self:_ensure_terminal(opts.cmd, opts.on_create)
  vim.api.nvim_win_set_buf(self.win, self.buf)
  vim.cmd.startinsert()
end

---Start the terminal process in the background without opening a visible window.
---
---Opens a temporary off-screen window just long enough to attach the terminal
---job, then immediately hides it.  Subsequent toggle() calls reuse the
---already-running session.
---@param cmd string Command to run.
---@param on_create? fun(win: number) Called with the temporary window before the job starts.
function Terminal:start_hidden(cmd, on_create)
  if is_terminal_buffer(self.buf) then return end
  self.buf = ensure_hidden_buffer(self.buf)

  local tmp_win = vim.api.nvim_open_win(self.buf, false, {
    relative = "editor", row = 0, col = 0,
    width = 1, height = 1,
    style = "minimal", noautocmd = true,
  })
  local saved_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(tmp_win)

  self:_start_job(cmd, on_create)

  vim.api.nvim_win_hide(tmp_win)
  vim.api.nvim_set_current_win(saved_win)
end

---Stop the terminal, killing its job and cleaning up state.
function Terminal:stop()
  local job_id = vim.api.nvim_buf_is_valid(self.buf) and vim.b[self.buf].terminal_job_id
  if job_id then vim.fn.jobstop(job_id) end
  if vim.api.nvim_win_is_valid(self.win) then vim.api.nvim_win_close(self.win, true) end
  if vim.api.nvim_buf_is_valid(self.buf) then vim.api.nvim_buf_delete(self.buf, { force = true }) end
  self.buf = -1
  self.win = -1
  self.layout = nil
end

---Return whether the terminal window is currently visible in the active tab.
---@return boolean
function Terminal:is_visible()
  return is_window_in_current_tab(self.win) and self.layout ~= nil
end

---Return the terminal's buffer number if valid, nil otherwise.
---@return number?
function Terminal:bufnr()
  return vim.api.nvim_buf_is_valid(self.buf) and self.buf or nil
end

-- ---------------------------------------------------------------------------
-- Module: pre-built instances and keymap registration
-- ---------------------------------------------------------------------------

---@class TerminalModule
local M = {}

M.split = Terminal.new()
M.float = Terminal.new("float", open_float)

---Register keymaps for the dedicated split and floating terminals.
M.init = function()
  vim.keymap.set("n", "<leader>tl", function()
    M.split:toggle({ layout = "right", open_win = function(buf) return open_split(buf, "right") end })
  end, { desc = "Open terminal in vertical split on the right" })

  vim.keymap.set("n", "<leader>tj", function()
    M.split:toggle({ layout = "below", open_win = function(buf) return open_split(buf, "below") end })
  end, { desc = "Open terminal in horizontal split on the bottom" })

  vim.keymap.set({ "n", "t" }, "<C-\\>", function()
    M.float:toggle()
  end, { desc = "Toggle floating terminal" })
end

return M
