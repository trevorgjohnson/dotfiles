--- AI tooling: claudecode.nvim / opencode.nvim integration + context-yank helpers.
---
--- Priority: claude (claudecode.nvim) > opencode (opencode.nvim) > fallback.
--- When neither is installed, falls back to yank-based keymaps that pair with
--- a plain Claude Code terminal float toggled via <C-\>.
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

---Register the context-yank keymaps shared by claudecode and the bare fallback.
local function register_yank_keymaps()
  vim.keymap.set("n", "ayy", yank_current_line,
    { desc = "[]: [Y]ank line context for AI" })
  vim.keymap.set({ "v", "x" }, "<leader>ay", yank_visual_range,
    { desc = "[]: [Y]ank range context for AI" })
end

-- ---------------------------------------------------------------------------
-- claudecode.nvim custom terminal provider (backed by user.terminal float)
-- ---------------------------------------------------------------------------

---Build a custom terminal provider that delegates to the shared float terminal
---so claudecode.nvim reuses the same <C-\> session instead of its own split.
---@param term table user.terminal module
---@return table provider
local function make_claude_provider(term)
  ---Set process-level env vars so the next jobstart inherits them.
  ---@param env table<string, string>
  local function apply_env(env)
    for k, v in pairs(env) do
      vim.env[k] = v
    end
  end

  return {
    setup = function() end,

    open = function(cmd, env, _, focus)
      apply_env(env)
      if not term.float:is_visible() then
        term.float:toggle({ cmd = cmd })
      elseif focus ~= false then
        -- Already visible — just make sure it's focused.
        term.float:toggle({ cmd = cmd }) -- toggles to hide
        term.float:toggle({ cmd = cmd }) -- toggles back to show (focused)
      end
    end,

    close = function()
      if term.float:is_visible() then
        term.float:toggle()
      end
    end,

    simple_toggle = function(cmd, env)
      apply_env(env)
      term.float:toggle({ cmd = cmd })
    end,

    focus_toggle = function(cmd, env)
      apply_env(env)
      term.float:toggle({ cmd = cmd })
    end,

    get_active_bufnr = function()
      return term.float:bufnr()
    end,

    is_available = function()
      return true
    end,
  }
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

---Register AI keymaps and return the lazy plugin spec.
---
---Returns claudecode.nvim spec when `claude` is installed, opencode.nvim spec
---when `opencode` is installed, or an empty table with bare yank keymaps as
---a fallback.
---@return table lazy plugin spec
function M.setup()
  local term = require("user.terminal")

  -- ----- claudecode.nvim (highest priority) --------------------------------
  if vim.fn.executable("claude") == 1 then
    register_yank_keymaps()
    return {
      "coder/claudecode.nvim",
      keys = {
        {
          "<leader>ap",
          "<cmd>ClaudeCodeSend<cr>",
          mode = { "v", "x" },
          desc = "[]: [P]rompt Claude on selection"
        },
      },
      opts = {
        terminal = {
          provider = make_claude_provider(term),
        },
      },
    }
  end

  -- ----- opencode.nvim -----------------------------------------------------
  if vim.fn.executable("opencode") == 1 then
    return {
      "nickjvandyke/opencode.nvim",
      version = "*", -- Latest stable release
      keys = {
        { "<leader>ap", function() require("opencode").ask("@this: ", { submit = true }) end,
          mode = { "v", "x" }, desc = "[]: [P]rompt Opencode on selection" },
        { "<leader>ay", function() return require("opencode").operator("@this ") end,
          mode = { "v", "x" }, desc = "[]: [Y]ank range context and send to AI", expr = true },
        { "ayy", function() return require("opencode").operator("@this ") .. "_" end,
          mode = "n", desc = "[]: [Y]ank line context and send to AI", expr = true },
      },
      config = function()
        -- Configure the opencode's server callbacks to use the float term under user.terminal
        require("opencode.config").opts.server = {
          start  = function() term.float:start_hidden("opencode --port", opencode_terminal_setup) end,
          stop   = function() term.float:stop() end,
          toggle = function() term.float:toggle({ cmd = "opencode --port", on_create = opencode_terminal_setup }) end,
        }
      end,
    }
  end

  -- ----- Bare fallback (no AI CLI installed) --------------------------------
  register_yank_keymaps()
  vim.keymap.set({ "v", "x" }, "<leader>ap", function()
    yank_visual_range()
    vim.schedule(function() term.float:toggle() end)
  end, { desc = "[]: [P]rompt AI — yank context + open terminal float" })

  return {}
end

return M
