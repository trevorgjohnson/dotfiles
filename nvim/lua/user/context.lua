local M = {}
local highlight_namespace = vim.api.nvim_create_namespace("context-yank-highlight")

---Flash a line range briefly to confirm a context copy action.
---
---@param start_line integer 1-based inclusive
---@param end_line integer 1-based inclusive
local function flash_line_range(start_line, end_line)
  vim.hl.range(
    vim.api.nvim_get_current_buf(),
    highlight_namespace,
    "ContextYank",
    { start_line - 1, 0 },
    { end_line - 1, 0 },
    { regtype = "V", inclusive = true, timeout = 160 }
  )
end

---Yank text into both the system clipboard and Neovim's unnamed register.
---Also prepends @ before the text which is often used by LLMs for streamlined lookups
---@param text string
local function copy_to_clipboard(text)
  vim.fn.setreg("+", '@'..text)
  vim.fn.setreg('"', '@'..text)
end

---Return the current buffer path relative to the working directory.
---
---The relative form is what we usually want when sharing a location in the
---repo, and it keeps notifications and pasted references compact.
---
---@return string
local function current_file_path()
  return vim.fn.expand("%:.")
end

---Yank the current buffer path.
---
---The result is relative to the current working directory so it can be pasted
---directly into code review comments, terminal commands, or chat.
local function copy_current_file_path()
  copy_to_clipboard(current_file_path())
end

---Yank a `path:line` reference for the cursor position.
---
---This produces a compact location string that can be used in notes, review
---comments, and editor integrations that understand file references.
local function copy_current_file_line()
  copy_to_clipboard(string.format("%s:%d", current_file_path(), vim.fn.line(".")))
  flash_line_range(vim.fn.line("."), vim.fn.line("."))
end

---Yank a `path:start-end` reference for the current visual selection.
---
---The function normalizes the selected line order so the range is always
---reported from the lower line to the higher line, regardless of selection
---direction.
local function copy_visual_file_range()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
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

---Register context-oriented keymaps.
function M.init()
  vim.keymap.set("n", "<leader>yp", copy_current_file_path, { desc = "[Y]ank [P]ath context" })
  vim.keymap.set("n", "<leader>yy", copy_current_file_line, { desc = "[Y]ank context for the line" })
  vim.keymap.set("x", "<leader>y", copy_visual_file_range, { desc = "[Y]ank context for the range" })
end

return M
