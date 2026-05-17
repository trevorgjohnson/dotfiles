local yank_ns = vim.api.nvim_create_namespace("context-yank-highlight")

-- Copies and puts `text` into both + and " registers
-- Also flashes the copied text briefly with the "ContextYank" hlgroup
local function copy_to_clipboard(text, start_line, end_line)
  vim.fn.setreg("+", "@" .. text)
  vim.fn.setreg('"', "@" .. text)
  vim.hl.range(
    vim.api.nvim_get_current_buf(),
    yank_ns,
    "ContextYank",
    { start_line - 1, 0 },
    { end_line - 1, 0 },
    { regtype = "V", inclusive = true, timeout = 160 }
  )
end

local function yank_visual_range()
  local start_line = vim.fn.line("v")
  local end_line   = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  copy_to_clipboard(
    string.format("%s#L%d-%d", vim.fn.expand("%:."), start_line, end_line),
    start_line, end_line
  )

  -- Clear the active visual selection first so the timed range highlight is visible.
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  vim.schedule(function()
    flash_line_range()
  end)
end

vim.keymap.set("n", "ayy", function() 
  copy_to_clipboard(
    string.format("%s#L%d", vim.fn.expand("%:."), vim.fn.line(".")),
    vim.fn.line("."), vim.fn.line(".")
  ) end,
  { desc = "[]: [Y]ank line and path context" })

vim.keymap.set({ "v", "x" }, "<leader>ay", function() 
  copy_to_clipboard(
    string.format("%s#L%d-%d", vim.fn.expand("%:."), vim.fn.line("v"), vim.fn.line(".")),
    vim.fn.line("v"), vim.fn.line(".")
  ) end,
  { desc = "[]: [Y]ank range and path context" })
