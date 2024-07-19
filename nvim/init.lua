local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
        local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
        vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
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
                opts = {
                        default_integrations = true,
                        transparent_background = true,
                        flavour = "mocha",
                        term_colors = true,
                        ---@class CtpColors<T>: {rosewater: T, flamingo: T, pink: T, mauve: T, red: T, maroon: T, peach: T, yellow: T, green: T, teal: T, sky: T, sapphire: T, blue: T, lavender: T, text: T, subtext1: T, subtext0: T, overlay2: T, overlay1: T, overlay0: T, surface2: T, surface1: T, surface0: T, base: T, mantle: T, crust: T, none: T }
                        ---@param colors CtpColors<string>
                        custom_highlights = function(colors)
                                return {
                                        DiagnosticVirtualTextError = { bg = colors.surface0 },
                                        CurSearch = { bg = colors.mauve }
                                }
                        end
                },
                init = function() vim.cmd.colorscheme 'catppuccin-mocha' end
        },

        {
                "folke/tokyonight.nvim",
                lazy = false,
                priority = 1000,
                opts = { style = "moon", transparent = true },
        },

        { "wuwe1/vim-huff",                 ft = "huff" }, -- Huff helpers

        {
                "norcalli/nvim-colorizer.lua",
                event = { "BufReadPre", "BufNewFile" },
                opts = {},
        },

        {
                "folke/todo-comments.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
                event = { "BufReadPre", "BufNewFile" },
                opts = { signs = true },
                keys = { { '<leader>x', "<cmd>TodoQuickFix<cr>", { desc = 'Open quickfix list searching for todo comments' }, } }
        },

        {
                "lukas-reineke/indent-blankline.nvim",
                event = { "BufReadPre", "BufNewFile" },
                main = "ibl",
                opts = {}
        },

        {
                "stevearc/conform.nvim",
                event = { "BufWritePre" },
                cmd = { "ConformInfo" },
                keys = {
                        { '<leader>fm',
                                function()
                                        require("conform").format({ async = true, lsp_fallback = true })
                                end,
                                { desc = '[f]or[m]at buffer' },
                        }
                },
                opts = {
                        formatters_by_ft = {
                                typescript = { "prettier" },
                                rust = { "rustfmt" }
                        }
                },
        },

        {
                "iamcco/markdown-preview.nvim",
                ft = "markdown",
                build = function() vim.fn["mkdp#util#install"]() end,
        },


        {
                'akinsho/bufferline.nvim',
                -- version = "*", -- <-- until [EC108](https://github.com/akinsho/bufferline.nvim/issues/903) is resolved
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
                opts = {}
        },

        {
                'akinsho/toggleterm.nvim',
                version = "*",
                keys = {
                        { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" }
                },
                config = function()
                        require("toggleterm").setup {
                                open_mapping = [[<c-\>]],
                                direction = "float",
                                float_opts = {
                                        border = "curved",
                                        winblend = 0,
                                },
                                persist_mode = true,
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
                opts = {
                        ensure_installed = { "rust", "solidity", "lua", "typescript", "javascript" },
                        auto_install = true,
                        highlight = { enable = true }
                },
                config = function(_, opts)
                        require('nvim-treesitter.install').prefer_git = true
                        ---@diagnostic disable-next-line: missing-fields
                        require('nvim-treesitter.configs').setup(opts)
                end,
        },

        { -- git decorations
                "lewis6991/gitsigns.nvim",
                event = { "BufReadPre", "BufNewFile" },
                opts = {
                        current_line_blame_opts = { delay = 250, },
                        current_line_blame_formatter = " <author>, <author_time:%R> - <summary> ",
                        preview_config = { border = "rounded", },
                        on_attach = function(bufnr)
                                local gs = package.loaded.gitsigns

                                local nmap = function(keys, func, desc)
                                        vim.keymap.set('n', keys, func,
                                                { buffer = bufnr, desc = '[󰊢 ]: ' .. desc })
                                end

                                -- Navigation
                                nmap('[h', function()
                                        if vim.wo.diff then return '[c' end
                                        vim.schedule(function() gs.prev_hunk() end)
                                        return '<Ignore>'
                                end, "Previous [H]unk")

                                nmap(']h', function()
                                        if vim.wo.diff then return ']c' end
                                        vim.schedule(function() gs.next_hunk() end)
                                        return '<Ignore>'
                                end, "Next [H]unk")

                                nmap('<leader>rh', gs.reset_hunk, "[r]eset [h]unk")
                                nmap('<leader>ph', gs.preview_hunk, "[p]review [h]unk")
                                nmap('<leader>sb', function() gs.blame_line { full = true } end, "[s]how [b]lame")
                                nmap('<leader>tb', gs.toggle_current_line_blame, "[t]oggle [b]lame")
                                nmap('<leader>sd', gs.diffthis, "[s]how [d]iff")
                        end
                }
        },

        { -- status line at the bottom
                "nvim-lualine/lualine.nvim",
                dependencies = { "nvim-tree/nvim-web-devicons" },
                config = function()
                        local branch = {
                                "branch",
                                icons_enabled = true,
                                icon = "",
                        }

                        local diff = {
                                "diff",
                                colored = true,
                                symbols = { added = " ", modified = " ", removed = " " },
                        }

                        local lazy_status = {
                                require('lazy.status').updates,
                                cond = require('lazy.status').has_updates,
                        }

                        require("lualine").setup {
                                options = {
                                        icons_enabled = true,
                                        theme = "auto",
                                        component_separators = { left = '|', right = '|' }, -- { left = '', right = ''},
                                        section_separators = { left = '', right = '' },
                                        globalstatus = true,
                                },
                                sections = {
                                        lualine_a = { 'mode' },
                                        lualine_b = { branch },
                                        lualine_c = { diff },
                                        lualine_x = { lazy_status },
                                        lualine_y = { 'filetype' },
                                        lualine_z = { 'progress' }
                                },
                        }
                end
        },

        { import = 'user.plugins.telescope' },
        { import = 'user.plugins.nvim-cmp' },
        { import = 'user.plugins.lspconfig' },
}, {
        install = { colorscheme = { 'catppuccin-mocha' } },
        ui = { border = "rounded" },
        checker = {
                enabled = true,
                notify = false,
        },
        change_detection = { notify = false }

})
