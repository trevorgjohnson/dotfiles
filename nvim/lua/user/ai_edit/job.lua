---Async AI edit job capture and execution helpers.
---
---Phase 1 focuses on:
---1. Capturing the current visual selection with nearby read-only context.
---2. Persisting a job record under Neovim's state directory.
---3. Running a configured CLI asynchronously and storing its output.
local M = {}

---@class AiEditConfig
---@field cli string[]
---@field context_lines integer

---@class AiEditSelection
---@field start_row integer 0-based inclusive
---@field start_col integer 0-based inclusive
---@field end_row integer 0-based inclusive
---@field end_col integer 0-based exclusive
---@field start_line integer 1-based inclusive
---@field end_line integer 1-based inclusive
---@field mode string

---@class AiEditRequest
---@field job_id string
---@field created_at string
---@field cwd string
---@field file_path string
---@field filetype string
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer
---@field selected_start_line integer
---@field selected_end_line integer
---@field context_start_line integer
---@field context_end_line integer
---@field selected_text_hash string
---@field selected_text_byte_count integer
---@field context_before string
---@field selected_text string
---@field context_after string
---@field prompt string
---@field status string

local STATUS_RUNNING = "running"
local STATUS_READY = "ready"
local STATUS_FAILED = "failed"
local STATUS_STALE = "stale"
local STATUS_APPLIED = "applied"
local STATUS_DISMISSED = "dismissed"

---@param lines string[]
---@return string
local function join_lines(lines)
  return table.concat(lines, "\n")
end

---@param path string
---@param content string
local function write_text(path, content)
  local file, err = io.open(path, "wb")
  if not file then
    error(string.format("failed to open %s: %s", path, err or "unknown error"))
  end

  file:write(content)
  file:close()
end

---@param path string
---@param data table
local function write_json(path, data)
  write_text(path, vim.json.encode(data))
end

---@param path string
---@return string
local function read_text(path)
  local file = io.open(path, "rb")
  if not file then
    return ""
  end

  local content = file:read("*a") or ""
  file:close()
  return content
end

---@param path string
---@return table|nil
local function read_json(path)
  local content = read_text(path)
  if content == "" then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end

  return decoded
end

---@param text string
---@return string
local function sanitize_message(text)
  if text == nil or text == "" then
    return ""
  end

  local cleaned = text
    :gsub("\27%[[0-9;?]*[ -/]*[@-~]", "")
    :gsub("\27%][^\7]*\7", "")
    :gsub("[%c]", " ")
    :gsub("%s+", " ")

  return vim.trim(cleaned)
end

---@param text string
---@return string
local function summarize_message(text)
  local first_line = sanitize_message((text or ""):match("([^\n]+)") or "")
  if first_line == "" then
    return "no error details"
  end

  return first_line
end

---@param result table
---@return string
local function failure_details(result)
  local detail = summarize_message((result.stderr or "") ~= "" and result.stderr or tostring(result.err or ""))
  local code = result.code
  if code == nil then
    return detail
  end

  return string.format("exit %s: %s", tostring(code), detail)
end

---@return string
local function state_root()
  return vim.fs.joinpath(vim.fn.stdpath("state"), "ai-edit")
end

---@return string
local function jobs_root()
  return vim.fs.joinpath(state_root(), "jobs")
end

---@param job_id string
---@return string
local function job_dir(job_id)
  return vim.fs.joinpath(jobs_root(), job_id)
end

---@param path string
local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

---@return string
local function new_job_id()
  local stamp = os.date("%Y%m%d-%H%M%S")
  local suffix = tostring(vim.uv.hrtime() % 1000000)
  return string.format("%s-%s", stamp, suffix)
end

---@param text string
---@return string
local function text_hash(text)
  return tostring(vim.fn.sha256(text))
end

---@param buf integer
---@return string
local function buffer_file_path(buf)
  return vim.api.nvim_buf_get_name(buf)
end

---@param buf integer
---@return boolean
local function is_file_buffer(buf)
  return vim.bo[buf].buftype == "" and buffer_file_path(buf) ~= ""
end

---@param buf integer
---@return AiEditSelection
local function current_visual_selection(buf)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local mode = vim.fn.visualmode()

  if mode == "\022" then
    error("blockwise visual selection is not supported in v1")
  end

  local start_row = start_pos[2] - 1
  local start_col = math.max(start_pos[3] - 1, 0)
  local end_row = end_pos[2] - 1
  local end_col_inclusive = math.max(end_pos[3] - 1, 0)

  if start_row > end_row or (start_row == end_row and start_col > end_col_inclusive) then
    start_row, end_row = end_row, start_row
    start_col, end_col_inclusive = end_col_inclusive, start_col
  end

  if mode == "V" then
    local end_line_text = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1] or ""
    start_col = 0
    end_col_inclusive = math.max(#end_line_text - 1, 0)
  end

  return {
    start_row = start_row,
    start_col = start_col,
    end_row = end_row,
    end_col = end_col_inclusive + 1,
    start_line = start_row + 1,
    end_line = end_row + 1,
    mode = mode,
  }
end

---@param buf integer
---@param selection AiEditSelection
---@return string
local function selected_text(buf, selection)
  local chunks = vim.api.nvim_buf_get_text(
    buf,
    selection.start_row,
    selection.start_col,
    selection.end_row,
    selection.end_col,
    {}
  )
  return join_lines(chunks)
end

---@param buf integer
---@param start_line integer 1-based inclusive
---@param end_line integer 1-based inclusive
---@return string
local function line_slice(buf, start_line, end_line)
  if end_line < start_line then
    return ""
  end

  local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
  return join_lines(lines)
end

---@param request AiEditRequest
---@return string
local function build_prompt(request)
  return table.concat({
    "You are editing code inside Neovim.",
    "Use the surrounding context only for reference.",
    "Rewrite only the selected text.",
    "Return only the replacement text for the selected text.",
    "Do not include markdown fences or commentary.",
    "",
    "File: " .. request.file_path,
    "Filetype: " .. request.filetype,
    string.format("Selected lines: %d-%d", request.selected_start_line, request.selected_end_line),
    "",
    "Instruction:",
    request.prompt,
    "",
    "Context before:",
    request.context_before,
    "",
    "Selected text to rewrite:",
    request.selected_text,
    "",
    "Context after:",
    request.context_after,
  }, "\n")
end

---@param config AiEditConfig
---@param prompt string
---@return AiEditRequest, string
local function build_request(config, prompt)
  local buf = vim.api.nvim_get_current_buf()
  if not is_file_buffer(buf) then
    error("AIEdit requires a file-backed buffer")
  end

  local selection = current_visual_selection(buf)
  local picked_text = selected_text(buf, selection)
  if picked_text == "" then
    error("AIEdit requires a non-empty visual selection")
  end

  local total_lines = vim.api.nvim_buf_line_count(buf)
  local context_start_line = math.max(1, selection.start_line - config.context_lines)
  local context_end_line = math.min(total_lines, selection.end_line + config.context_lines)
  local before_text = line_slice(buf, context_start_line, selection.start_line - 1)
  local after_text = line_slice(buf, selection.end_line + 1, context_end_line)
  local request = {
    job_id = new_job_id(),
    created_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    cwd = vim.fn.getcwd(),
    file_path = buffer_file_path(buf),
    filetype = vim.bo[buf].filetype,
    start_row = selection.start_row,
    start_col = selection.start_col,
    end_row = selection.end_row,
    end_col = selection.end_col,
    selected_start_line = selection.start_line,
    selected_end_line = selection.end_line,
    context_start_line = context_start_line,
    context_end_line = context_end_line,
    selected_text_hash = text_hash(picked_text),
    selected_text_byte_count = #picked_text,
    context_before = before_text,
    selected_text = picked_text,
    context_after = after_text,
    prompt = prompt,
    status = STATUS_RUNNING,
  }

  return request, build_prompt(request)
end

---@param job_dir string
---@param request AiEditRequest
---@param result table
---@param status string
local function write_status(job_dir, request, result, status)
  write_json(vim.fs.joinpath(job_dir, "status.json"), {
    job_id = request.job_id,
    status = status,
    updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    exit_code = result.code,
    signal = result.signal,
    result_path = vim.fs.joinpath(job_dir, "result.txt"),
    stdout_path = vim.fs.joinpath(job_dir, "stdout.txt"),
    stderr_path = vim.fs.joinpath(job_dir, "stderr.txt"),
    error = result.err,
  })
end

---@class AiEditStoredJob
---@field job_id string
---@field dir string
---@field request table
---@field status table
---@field original_text string
---@field result_text string
---@field stdout string
---@field stderr string

---@return string[]
local function list_job_ids()
  local root = jobs_root()
  local handle = vim.uv.fs_scandir(root)
  if not handle then
    return {}
  end

  local ids = {}
  while true do
    local name, kind = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    if kind == "directory" then
      table.insert(ids, name)
    end
  end

  table.sort(ids, function(left, right)
    return left > right
  end)
  return ids
end

---@param job_id string
---@return AiEditStoredJob|nil
function M.load(job_id)
  local dir = job_dir(job_id)
  local request = read_json(vim.fs.joinpath(dir, "request.json"))
  local status = read_json(vim.fs.joinpath(dir, "status.json"))
  if not request or not status then
    return nil
  end

  return {
    job_id = job_id,
    dir = dir,
    request = request,
    status = status,
    original_text = read_text(vim.fs.joinpath(dir, "original.txt")),
    result_text = read_text(vim.fs.joinpath(dir, "result.txt")),
    stdout = read_text(vim.fs.joinpath(dir, "stdout.txt")),
    stderr = read_text(vim.fs.joinpath(dir, "stderr.txt")),
  }
end

---@param job_id string
---@param status string
---@param fields table|nil
function M.update_status(job_id, status, fields)
  local job = M.load(job_id)
  if not job then
    return false
  end

  local updated = vim.tbl_extend("force", job.status, fields or {}, {
    job_id = job_id,
    status = status,
    updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
  })
  write_json(vim.fs.joinpath(job.dir, "status.json"), updated)
  return true
end

---@return AiEditStoredJob[]
function M.list_all()
  local jobs = {}
  for _, job_id in ipairs(list_job_ids()) do
    local job = M.load(job_id)
    if job then
      table.insert(jobs, job)
    end
  end

  return jobs
end

---@param status string
---@return boolean
local function is_open_status(status)
  return status == STATUS_READY or status == STATUS_STALE
end

---@return AiEditStoredJob[]
function M.list_open()
  local jobs = {}
  for _, job in ipairs(M.list_all()) do
    if is_open_status(job.status.status) then
      table.insert(jobs, job)
    end
  end

  return jobs
end

---@param file_path string
---@return AiEditStoredJob|nil
function M.latest_open_for_file(file_path)
  for _, job in ipairs(M.list_open()) do
    if job.request.file_path == file_path then
      return job
    end
  end

  return nil
end

function M.rebuild_qflist()
  local review = require("user.ai_edit.review")
  local items = {}
  for _, job in ipairs(M.list_open()) do
    local review_buf = review.ensure_buffer(job)
    table.insert(items, {
      bufnr = review_buf,
      lnum = 1,
      col = 1,
      text = string.format(
        "[ai-edit %s] %s",
        job.status.status,
        vim.fn.strcharpart(vim.trim(job.request.prompt or ""), 0, 60)
      ),
      user_data = {
        job_id = job.job_id,
      },
    })
  end

  vim.fn.setqflist({}, "r", {
    title = "AI Edit Open Jobs",
    context = {
      ai_edit = true,
    },
    items = items,
  })
  vim.cmd("copen")
end

M.status = {
  READY = STATUS_READY,
  STALE = STATUS_STALE,
  APPLIED = STATUS_APPLIED,
  DISMISSED = STATUS_DISMISSED,
}

---@param config AiEditConfig
---@param prompt_arg string
function M.start(config, prompt_arg)
  local prompt = vim.trim(prompt_arg ~= "" and prompt_arg or vim.fn.input("AI edit prompt: "))
  if prompt == "" then
    vim.notify("AIEdit cancelled: prompt required", vim.log.levels.WARN)
    return
  end

  local ok, request, cli_prompt = pcall(build_request, config, prompt)
  if not ok then
    vim.notify(request, vim.log.levels.ERROR)
    return
  end

  ensure_dir(jobs_root())
  local job_dir = vim.fs.joinpath(jobs_root(), request.job_id)
  ensure_dir(job_dir)

  write_json(vim.fs.joinpath(job_dir, "request.json"), request)
  write_text(vim.fs.joinpath(job_dir, "prompt.txt"), cli_prompt)
  write_text(vim.fs.joinpath(job_dir, "original.txt"), request.selected_text)
  write_text(vim.fs.joinpath(job_dir, "stdout.txt"), "")
  write_text(vim.fs.joinpath(job_dir, "stderr.txt"), "")
  write_status(job_dir, request, { code = nil, signal = nil, err = nil }, STATUS_RUNNING)

  local command = vim.deepcopy(config.cli)
  table.insert(command, cli_prompt)

  vim.notify(
    string.format("AI edit started: %s:%d", vim.fn.fnamemodify(request.file_path, ":."), request.selected_start_line),
    vim.log.levels.INFO
  )

  vim.system(command, { text = true }, vim.schedule_wrap(function(result)
    local ok, callback_err = pcall(function()
      write_text(vim.fs.joinpath(job_dir, "stdout.txt"), result.stdout or "")
      write_text(vim.fs.joinpath(job_dir, "stderr.txt"), result.stderr or "")

      local success = result.code == 0 and vim.trim(result.stdout or "") ~= ""
      if success then
        write_text(vim.fs.joinpath(job_dir, "result.txt"), result.stdout)
        write_status(job_dir, request, result, STATUS_READY)
        vim.notify(
          string.format(
            "AI edit ready: %s:%d",
            vim.fn.fnamemodify(request.file_path, ":."),
            request.selected_start_line
          ),
          vim.log.levels.INFO
        )
        return
      end

      write_status(job_dir, request, result, STATUS_FAILED)
      vim.notify(
        string.format(
          "AI edit failed: %s:%d (%s)",
          vim.fn.fnamemodify(request.file_path, ":."),
          request.selected_start_line,
          failure_details(result)
        ),
        vim.log.levels.ERROR
      )
    end)

    if ok then
      return
    end

    local internal_error = tostring(callback_err)
    pcall(write_text, vim.fs.joinpath(job_dir, "stderr.txt"), internal_error)
    pcall(write_status, job_dir, request, { code = result.code, signal = result.signal, err = internal_error }, STATUS_FAILED)
    vim.notify(
      string.format(
        "AI edit runner error: %s:%d (%s)",
        vim.fn.fnamemodify(request.file_path, ":."),
        request.selected_start_line,
        summarize_message(internal_error)
      ),
      vim.log.levels.ERROR
    )
  end))
end

return M
