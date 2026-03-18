--- AI tooling: opencode.nvim integration + context-yank helpers.
---
--- When opencode is installed, loads the opencode.nvim plugin with full
--- structured ask/operator/select support. Otherwise, falls back to
--- yank-based keymaps that pair with a plain Claude Code terminal float.
local M = {}

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

local yank_ns = vim.api.nvim_create_namespace("context-yank-highlight")

---Flash a line range briefly to confirm a context copy action.
---@param start_line integer 1-based inclusive
---@param end_line integer 1-based inclusive
local function flash_line_range(start_line, end_line)
  vim.hl.range(
    vim.api.nvim_get_current_buf(),
    yank_ns,
    "ContextYank",
    { start_line - 1, 0 },
    { end_line - 1, 0 },
    { regtype = "V", inclusive = true, timeout = 160 }
  )
end

---Yank text into both the system clipboard and Neovim's unnamed register.
---Prepends @ before the text which is often used by LLMs for streamlined lookups.
---@param text string
local function copy_to_clipboard(text)
  vim.fn.setreg("+", "@" .. text)
  vim.fn.setreg('"', "@" .. text)
end

---Return the current buffer path relative to the working directory.
---@return string
local function current_file_path()
  return vim.fn.expand("%:.")
end

---Copy `@file:line` to the clipboard and flash the line.
local function yank_current_line()
  copy_to_clipboard(string.format("%s:%d", current_file_path(), vim.fn.line(".")))
  flash_line_range(vim.fn.line("."), vim.fn.line("."))
end

---Copy `@file:start-end` for the visual selection and flash the range.
local function yank_visual_range()
  local start_line = vim.fn.line("v")
  local end_line   = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  copy_to_clipboard(string.format("%s:%d-%d", current_file_path(), start_line, end_line))

  -- Clear the active visual selection first so the timed range highlight is visible.
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  vim.schedule(function()
    flash_line_range(start_line, end_line)
  end)
end

-- ---------------------------------------------------------------------------
-- Opencode pending-highlight helpers
-- ---------------------------------------------------------------------------

local pending_ns      = vim.api.nvim_create_namespace("opencode_ask_pending")
---@type integer? extmark id of the current pending highlight
local pending_mark_id = nil
---@type integer? buffer the pending mark lives in
local pending_buf     = nil

---Remove the pending highlight, if any.
local function clear_pending()
  if pending_buf and pending_mark_id then
    pcall(vim.api.nvim_buf_del_extmark, pending_buf, pending_ns, pending_mark_id)
  end
  pending_buf     = nil
  pending_mark_id = nil
end

---Highlight [start_row, end_row] (0-indexed, inclusive) in `buf` with
---OpencodeAskPending to signal that opencode is processing the selection.
---@param buf integer
---@param start_row integer 0-indexed
---@param end_row integer 0-indexed, inclusive
local function mark_pending(buf, start_row, end_row)
  clear_pending()
  pending_buf     = buf
  pending_mark_id = vim.api.nvim_buf_set_extmark(buf, pending_ns, start_row, 0, {
    end_row  = end_row + 1, -- extmark end is exclusive
    end_col  = 0,
    hl_group = "OpencodeAskPending",
    hl_eol   = true, -- extend highlight to end of each line
    priority = 200,
  })
end

---Setup callback passed to terminal helpers so opencode's keymaps and
---cleanup hooks are registered before the terminal job starts.
---@param win number
local function opencode_terminal_setup(win)
  require("opencode.terminal").setup(win)
end

-- ---------------------------------------------------------------------------
-- Module setup
-- ---------------------------------------------------------------------------

---Register AI keymaps and return the lazy plugin spec (empty when opencode
---is not installed, so the caller can always splice the result into lazy's
---spec list).
---@return table lazy plugin spec
function M.setup()
  local term = require("user.terminal")

  if vim.fn.executable("opencode") ~= 1 then
    vim.keymap.set("n", "ayy", yank_current_line,
      { desc = "[]: [Y]ank line context for AI" })
    vim.keymap.set({ "v", "x" }, "<leader>ay", yank_visual_range,
      { desc = "[]: [Y]ank range context for AI" })
    vim.keymap.set({ "v", "x" }, "<leader>ap", function()
      yank_visual_range()
      vim.schedule(function() term.toggle_float() end)
    end, { desc = "[]: [P]rompt AI — yank context + open claude float" })
    vim.keymap.set({ "n", "v", "x" }, "<leader>ao", function() term.toggle_float() end,
      { desc = "[]: Toggle Claude Code float" })
    return {}
  end

  return {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    event = "VimEnter",
    config = function()
      ---@type opencode.Opts
      -- FIX: enable when "safe" -> lsp = { enabled = true }
      vim.g.opencode_opts = {}

      -- vim.g doesn't support function values; set server hooks directly on the
      -- config module so opencode uses our float terminal instead of its own split.
      require("opencode.config").opts.server = {
        start  = function() term.start_float_hidden("opencode --port", opencode_terminal_setup) end,
        stop   = function() term.stop_float() end,
        toggle = function() term.toggle_float("opencode --port", opencode_terminal_setup) end,
      }

      local oc = require("opencode")
      vim.keymap.set({ "v", "x" }, "<leader>ap", function()
        local buf       = vim.api.nvim_get_current_buf()
        -- '<  / '> are set when leaving visual mode; still valid here.
        local start_row = vim.fn.line("'<") - 1 -- convert to 0-indexed
        local end_row   = vim.fn.line("'>") - 1
        mark_pending(buf, start_row, end_row)

        -- Open the float once the server starts processing the submitted prompt.
        vim.api.nvim_create_autocmd("User", {
          pattern  = "OpencodeEvent:session.busy",
          once     = true,
          callback = function() term.toggle_float("opencode --port", opencode_terminal_setup) end,
        })

        -- Clear pending highlight when opencode goes idle.
        vim.api.nvim_create_autocmd("User", {
          pattern  = "OpencodeEvent:session.idle",
          once     = true,
          callback = function() clear_pending() end,
        })

        oc.ask("@this: ", { submit = true })
      end, { desc = "[]: [P]rompt AI on selection" })
      vim.keymap.set({ "n", "v", "x" }, "<leader>ao", function() oc.select() end,
        { desc = "[]: Select from available AI [O]ptions" })
      vim.keymap.set({ "v", "x" }, "<leader>ay", function() return oc.operator("@this ") end,
        { desc = "[]: [Y]ank range context and send to AI", expr = true })
      vim.keymap.set("n", "ayy", function() return oc.operator("@this ") .. "_" end,
        { desc = "[]: [Y]ank line context and send to AI", expr = true })
      vim.keymap.set("n", "<C-a>u", function() oc.command("session.half.page.up") end,
        { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<C-a>d", function() oc.command("session.half.page.down") end,
        { desc = "Scroll opencode down" })
    end,
  }
end

return M
