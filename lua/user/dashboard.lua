local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

require("alpha.term")
local dashboard = require("alpha.themes.dashboard")

math.randomseed(os.time())
-- dashboard.section.header.val = "cat | lolcat --seed=27 " .. header
-- dashboard.section.header.opts.h1 = "hl_group"

local header = "cat | lolcat " ..
    os.getenv("HOME") .. "/.config/nvim/static/" .. math.random(3, 6) .. ".cat"

print(header)
dashboard.section.terminal.command = header
dashboard.section.terminal.width = 82
dashboard.section.terminal.height = 14

dashboard.section.buttons.val = {
  dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
  dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
  dashboard.button("p", "  Find project", ":Telescope project <CR>"),
  dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
  dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
  dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
  dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true

vim.cmd([[autocmd User AlphaReady echo 'ready']])
-- alpha.setup(dashboard.opts)

dashboard.config.layout = {
  { type = "padding", val = 7 },
  dashboard.section.terminal,
  { type = "padding", val = 9 },
  dashboard.section.buttons,
  { type = "padding", val = 1 },
  dashboard.section.footer,
}

alpha.setup(dashboard.opts)
