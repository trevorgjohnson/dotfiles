local M = {}

---Yank text into both the system clipboard and Neovim's unnamed register.
---
---This keeps the value available to external applications via `+` while also
---making normal paste operations inside Neovim behave as expected.
---
---@param text string
local function copy_to_clipboard(text)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify("Yanked: " .. text, vim.log.levels.INFO)
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
end

---Open a scratch vertical split containing the current file's git diff.
---
---The diff is resolved relative to the repository root so it works from any
---nested working directory. If the file is not in git, or there is no diff,
---the user gets a clear notification or placeholder buffer content.
local function show_current_file_git_diff()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("Current buffer has no file", vim.log.levels.WARN)
    return
  end

  local file_dir = vim.fn.fnamemodify(file, ":h")
  local git_root = vim.fn.systemlist({ "git", "-C", file_dir, "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 or not git_root then
    vim.notify("Current file is not in a git repository", vim.log.levels.WARN)
    return
  end

  local relative_file = vim.fn.fnamemodify(file, ":.")
  local repo_file = vim.fs.relpath(git_root, file)
  local diff = vim.fn.systemlist({ "git", "-C", git_root, "--no-pager", "diff", "--", repo_file })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to read git diff for current file", vim.log.levels.ERROR)
    return
  end

  if vim.tbl_isempty(diff) then
    diff = { "No git diff for " .. relative_file }
  end

  vim.cmd("botright vsplit")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "diff"
  vim.api.nvim_buf_set_name(buf, "git-diff://" .. repo_file)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, diff)
  vim.bo[buf].modifiable = false
end

---Register context-oriented keymaps.
---
---These mappings expose file and selection references as yanks so they fit
---Neovim vocabulary and keep all context-sharing actions together.
function M.init()
  vim.keymap.set("n", "<leader>yp", copy_current_file_path, { desc = "[Y]ank current file [P]ath" })
  vim.keymap.set("n", "<leader>yy", copy_current_file_line, { desc = "[Y]ank current file [L]ine" })
  vim.keymap.set("x", "<leader>y", copy_visual_file_range, { desc = "[Y]ank current file [L]ine range" })
  vim.keymap.set("n", "<leader>gd", show_current_file_git_diff, { desc = "Show [G]it [D]iff for the current file" })
end

return M
