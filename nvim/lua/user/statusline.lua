local M = {}

-- Don't show the command that produced the quickfix list.
vim.g.qf_disable_statusline = 1

-- Show the mode in my custom component instead.
vim.o.showmode = false

-- Show global status bar
vim.o.laststatus = 3

--- Current mode.
---@return string
function M.mode_component()
  local mode = vim.api.nvim_get_mode().mode or 'UNKNOWN'
  local hl = 'Other'
  if mode:find 'n' then
    hl = 'Normal'
  elseif mode:find 'v' then
    hl = 'Visual'
  elseif mode:find 'i' then
    hl = 'Insert'
  elseif mode:find 'c' or mode:find 't' then
    hl = 'Command'
  end
  return string.format('%%#StatuslineMode%s# %s ', hl, mode:upper())
end

--- Returns the git HEAD (if any)
function M.git_component()
  local head = vim.b.gitsigns_head
  if not head or head == '' then return '' end
  local MAX_BRANCH_WIDTH = math.floor(0.08 * vim.o.columns) -- 8% of total width
  if #head > MAX_BRANCH_WIDTH then head = vim.fn.strcharpart(head, 0, MAX_BRANCH_WIDTH) .. '…' end
  return string.format('%%#StatuslineGit#  %s ', head)
end

-- Returns information on the buffer's filetype
function M.filename()
  return string.format('%%#StatuslineFile# %s', vim.api.nvim_buf_get_name(0))
end

--- Renders the whole statusline
function M.render()
  return table.concat {
    M.filename(),
    '%#StatusLine#%=',
    M.mode_component(), M.git_component(),
  }
end

-- Initializes the statusline
function M.init()
  vim.o.statusline = "%!v:lua.require'user.statusline'.render()"
end

return M
