---Scratch review, diff, and apply helpers for persisted AI edit jobs.
local M = {}

local job_state = require("user.ai_edit.job")

---@param text string
---@return string[]
local function split_lines(text)
  if text == "" then
    return {}
  end

  return vim.split(text, "\n", { plain = true })
end

---@param lines string[]
---@param title string
---@param content string
local function append_section(lines, title, content)
  table.insert(lines, ("# %s"):format(title))
  if content == "" then
    table.insert(lines, "")
  else
    vim.list_extend(lines, split_lines(content))
  end
  table.insert(lines, "")
end

---@param job table
---@return string[]
local function review_lines(job)
  local lines = {
    "AI Edit Review",
    "",
    ("Job: %s"):format(job.job_id),
    ("Status: %s"):format(job.status.status),
    ("File: %s"):format(job.request.file_path),
    ("Range: %d-%d"):format(job.request.selected_start_line, job.request.selected_end_line),
    ("Created: %s"):format(job.request.created_at),
    "",
  }

  append_section(lines, "Prompt", job.request.prompt or "")
  append_section(lines, "Original", job.original_text or "")
  append_section(lines, "Proposed", job.result_text or job.stdout or "")

  if job.status.status == "failed" and (job.stderr or "") ~= "" then
    append_section(lines, "Stderr", job.stderr)
  end

  return lines
end

---@param name string
---@param filetype string
---@return integer
local function ensure_named_scratch(name, filetype)
  local buf = vim.fn.bufnr(name)
  if buf == -1 or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, name)
  end

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].readonly = false
  vim.bo[buf].filetype = filetype
  return buf
end

---@param job table
---@return integer
function M.ensure_buffer(job)
  local name = ("ai-edit-review://%s"):format(job.job_id)
  local buf = ensure_named_scratch(name, "markdown")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, review_lines(job))
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.b[buf].ai_edit_job_id = job.job_id
  return buf
end

---@param job table
---@return integer|nil
local function target_buffer(job)
  local path = job.request.file_path
  local current = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(current) == path then
    return current
  end

  local buf = vim.fn.bufnr(path)
  if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
    return buf
  end

  return nil
end

---@param buf integer
---@param job table
---@return string
local function current_selection_text(buf, job)
  local request = job.request
  local lines = vim.api.nvim_buf_get_text(
    buf,
    request.start_row,
    request.start_col,
    request.end_row,
    request.end_col,
    {}
  )
  return table.concat(lines, "\n")
end

---@param buf integer
---@param job table
local function jump_to_applied_range(buf, job)
  local request = job.request
  vim.api.nvim_set_current_buf(buf)
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(0, {
    request.selected_start_line,
    request.start_col,
  })
  vim.cmd("normal! zz")
end

---@param job table
---@return boolean
function M.apply(job)
  if (job.result_text or "") == "" then
    vim.notify("AI edit has no proposed result to apply", vim.log.levels.WARN)
    return false
  end

  local buf = target_buffer(job)
  if not buf then
    vim.notify("Open the target file buffer before applying this AI edit", vim.log.levels.WARN)
    return false
  end

  local current = current_selection_text(buf, job)
  if current ~= job.original_text then
    job_state.update_status(job.job_id, job_state.status.STALE)
    vim.notify("AI edit is stale; automatic apply was refused", vim.log.levels.WARN)
    return false
  end

  local replacement = split_lines(job.result_text)
  local request = job.request
  vim.api.nvim_buf_set_text(
    buf,
    request.start_row,
    request.start_col,
    request.end_row,
    request.end_col,
    replacement
  )
  job_state.update_status(job.job_id, job_state.status.APPLIED)
  jump_to_applied_range(buf, job)
  vim.notify(
    string.format(
      "AI edit applied: %s:%d",
      vim.fn.fnamemodify(job.request.file_path, ":."),
      job.request.selected_start_line
    ),
    vim.log.levels.INFO
  )
  return true
end

---@param label string
---@param job_id string
---@param filetype string
---@param content string
---@return integer
local function render_text_buffer(label, job_id, filetype, content)
  local buf = ensure_named_scratch(("ai-edit-%s://%s"):format(label, job_id), filetype)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, split_lines(content))
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  return buf
end

---@param job table
function M.open_diff(job)
  local buf = target_buffer(job)
  if not buf then
    vim.notify("Open the target file buffer before diffing this AI edit", vim.log.levels.WARN)
    return
  end

  local current_text = current_selection_text(buf, job)
  local filetype = job.request.filetype or ""
  local left = render_text_buffer("current", job.job_id, filetype, current_text)
  local right = render_text_buffer("proposed", job.job_id, filetype, job.result_text or job.stdout or "")

  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, left)
  vim.cmd("diffthis")
  vim.cmd("rightbelow vsplit")
  vim.api.nvim_win_set_buf(0, right)
  vim.cmd("diffthis")
  vim.cmd("wincmd h")
end

---@param job table
function M.open(job)
  local buf = M.ensure_buffer(job)
  vim.cmd("belowright split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

---@param job_id string
function M.open_by_id(job_id)
  local job = job_state.load(job_id)
  if not job then
    vim.notify(string.format("AI edit job not found: %s", job_id), vim.log.levels.WARN)
    return
  end

  M.open(job)
end

---@return table|nil
function M.current_job()
  local review_job_id = vim.b.ai_edit_job_id
  if review_job_id then
    return job_state.load(review_job_id)
  end

  local file_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  if file_path == "" then
    return nil
  end

  return job_state.latest_open_for_file(file_path)
end

---@param job table
---@return boolean
function M.dismiss(job)
  local review_buf = vim.api.nvim_get_current_buf()
  local is_review_buffer = vim.b.ai_edit_job_id == job.job_id

  local ok = job_state.update_status(job.job_id, job_state.status.DISMISSED)
  if not ok then
    vim.notify("Failed to dismiss AI edit job", vim.log.levels.WARN)
    return false
  end

  vim.notify(
    string.format(
      "AI edit dismissed: %s:%d",
      vim.fn.fnamemodify(job.request.file_path, ":."),
      job.request.selected_start_line
    ),
    vim.log.levels.INFO
  )

  if is_review_buffer and vim.api.nvim_buf_is_valid(review_buf) then
    vim.cmd("bdelete")
  end

  return true
end

return M
