---Minimal async AI edit workflow for reviewed code changes.
---
---Phase 1 includes:
---1. Visual range capture.
---2. Read-only surrounding context capture.
---3. Persisted job artifacts under `stdpath("state")`.
---4. Asynchronous CLI execution via `vim.system()`.
local M = {}

---@class AiEditConfig
---@field cli string[]|string
---@field context_lines integer

---@type AiEditConfig
local config = {
  cli = { "codex", "exec", "--skip-git-repo-check"},
  context_lines = 10,
}

local function current_file_path()
  return vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
end

local function review_latest_for_current_file()
  local review = require("user.ai_edit.review")
  local job = review.current_job()
  if not job then
    local file_path = current_file_path()
    if file_path == "" then
      vim.notify("AIEditReview requires a file-backed buffer", vim.log.levels.WARN)
      return
    end

    vim.notify("No open AI edit jobs for the current file", vim.log.levels.INFO)
    return
  end

  review.open(job)
end

local function rebuild_qflist()
  require("user.ai_edit.job").rebuild_qflist()
end

local function apply_current_job()
  local review = require("user.ai_edit.review")
  local job = review.current_job()
  if not job then
    vim.notify("No AI edit job is active for apply", vim.log.levels.INFO)
    return
  end

  review.apply(job)
end

local function diff_current_job()
  local review = require("user.ai_edit.review")
  local job = review.current_job()
  if not job then
    vim.notify("No AI edit job is active for diff", vim.log.levels.INFO)
    return
  end

  review.open_diff(job)
end

local function dismiss_current_job()
  local review = require("user.ai_edit.review")
  local job = review.current_job()
  if not job then
    vim.notify("No AI edit job is active for dismiss", vim.log.levels.INFO)
    return
  end

  review.dismiss(job)
end

---@param value string[]|string
---@return string[]
local function normalize_cli(value)
  if type(value) == "string" then
    return { value }
  end

  return vim.deepcopy(value)
end

---@param opts AiEditConfig|nil
function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_extend("force", config, opts)
  config.cli = normalize_cli(config.cli)

  vim.api.nvim_create_user_command("AIEdit", function(command_opts)
    require("user.ai_edit.job").start(config, command_opts.args)
  end, {
    desc = "Run an async AI edit for the current visual selection",
    nargs = "*",
    range = true,
  })
  vim.api.nvim_create_user_command("AIEditReview", review_latest_for_current_file, {
    desc = "Review the latest open AI edit for the current file",
  })
  vim.api.nvim_create_user_command("AIEditQf", rebuild_qflist, {
    desc = "Rebuild the quickfix list from open AI edit jobs",
  })
  vim.api.nvim_create_user_command("AIEditApply", apply_current_job, {
    desc = "Apply the active AI edit if the target range is unchanged",
  })
  vim.api.nvim_create_user_command("AIEditDiff", diff_current_job, {
    desc = "Open a diff between the current range and the proposed AI edit",
  })
  vim.api.nvim_create_user_command("AIEditDismiss", dismiss_current_job, {
    desc = "Dismiss the active AI edit without applying it",
  })

  vim.keymap.set("x", "<leader>ae", ":<C-u>AIEdit<CR>", { desc = "[]: Use [A]I to [E]dit selection" })
  vim.keymap.set("n", "<leader>ar", review_latest_for_current_file, { desc = "[]: Open the latest ready [A]I job to [R]eview" })
  vim.keymap.set("n", "<leader>aq", rebuild_qflist, { desc = "[]: Open all ready [A]I jobs in the [Q]uickfix list" })
  vim.keymap.set("n", "<leader>aa", apply_current_job, { desc = "[]: Mark open [A]I job as [A]pproved and apply it" })
  vim.keymap.set("n", "<leader>ad", diff_current_job, { desc = "[]: Open a tabpage showing current and proposed [A]I changes in a [D]iff split" })
  vim.keymap.set("n", "<leader>ax", dismiss_current_job, { desc = "[]: Mark open [A]I job as dismissed" })
end

return M
