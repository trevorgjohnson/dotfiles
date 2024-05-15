local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git",
                "--branch=stable", -- latest stable release
                lazypath,
        })
end
vim.opt.rtp:prepend(lazypath)

require('user.keymaps')
require('user.options')

require("lazy").setup({
        { -- Detect tabstop and shiftwidth automatically
                "tpope/vim-sleuth",
                event = { "BufReadPre", "BufNewFile" },
        },

        {
                "catppuccin/nvim",
                name = "catppuccin",
                priority = 1000,
                config = function()
                        require("catppuccin").setup({
                                transparent_background = true,
                                flavour = "mocha",
                                term_colors = true,
                        })

                        vim.cmd.colorscheme 'catppuccin-mocha'
                end
        },

        { "wuwe1/vim-huff",                 ft = "huff" }, -- Huff helpers

        {                                                  -- Comment helpers (gcc/gb)
                "numToStr/Comment.nvim",
                event = { "BufReadPre", "BufNewFile" },
                config = true
        },

        {
                "norcalli/nvim-colorizer.lua",
                event = { "BufReadPre", "BufNewFile" },
                config = true,
        },

        {
                "folke/todo-comments.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
                event = { "BufReadPre", "BufNewFile" },
                config = true,
                keys = { { '<leader>x', "<cmd>TodoQuickFix<cr>", { desc = 'Open quickfix list searching for todo comments' }, } }
        },

        {
                "lukas-reineke/indent-blankline.nvim",
                event = { "BufReadPre", "BufNewFile" },
                main = "ibl",
                opts = {}
        },

        {
                "iamcco/markdown-preview.nvim",
                ft = "markdown",
                build = function() vim.fn["mkdp#util#install"]() end,
        },


        {
                'akinsho/bufferline.nvim',
                version = "*",
                dependencies = { 'nvim-tree/nvim-web-devicons' },
                opts = {
                        options = {
                                offsets = { { filetype = "NvimTree", text = "File Explorer", padding = 1 } },
                        },
                }
        },

        {
                "nvim-tree/nvim-tree.lua",
                version = "*",
                dependencies = {
                        "nvim-tree/nvim-web-devicons",
                },
                keys = {
                        { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" }
                },
                config = true
        },

        {
                'akinsho/toggleterm.nvim',
                version = "*",
                keys = {
                        { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" }
                },
                config = function()
                        local mocha = require("catppuccin.palettes").get_palette "mocha"
                        require("toggleterm").setup {
                                open_mapping = [[<c-\>]],
                                direction = "float",
                                float_opts = {
                                        border = "curved",
                                        winblend = 0,
                                },
                                persist_mode = true,
                                highlights = {
                                        FloatBorder = {
                                                guifg = mocha.blue,
                                        },
                                },
                        }
                end
        },

        {
                'nvim-treesitter/nvim-treesitter',
                event = { "BufReadPre", "BufNewFile" },
                dependencies = {
                        'nvim-treesitter/nvim-treesitter-textobjects',
                },
                build = ':TSUpdate',
                config = function()
                        require("nvim-treesitter.configs").setup {
                                ensure_installed = { "rust", "solidity", "lua", "typescript", "javascript" },
                                highlight = { enable = true },
                        }

                        -- use treesitter folding
                        vim.o.foldlevel = 20
                        vim.o.foldmethod = "expr"
                        vim.o.foldexpr = "nvim_treesitter#foldexpr()"
                end,
        },

        { import = 'user.plugins.gitsigns' },
        { import = 'user.plugins.lspconfig' },
        { import = 'user.plugins.lualine' },
        { import = 'user.plugins.nvim-cmp' },
        { import = 'user.plugins.telescope' },
}, {
        install = { colorscheme = { 'catppuccin-mocha' } },
        checker = {
                enabled = true,
                notify = false,
        },
        change_detection = { notify = false }

})
