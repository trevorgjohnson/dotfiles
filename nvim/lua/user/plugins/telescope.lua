return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.5',
  dependencies = { 'nvim-lua/plenary.nvim', {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  } },
  keys = {
    { '<leader>?', "<cmd>Telescope oldfiles<cr>", {
      desc =
      '[?] Find recently opened files'
    }, },
    { '<leader><space>', "<cmd>Telescope buffers<cr>", {
      desc =
      '[ ] Find existing buffers'
    }, },
    { '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes')
          .get_dropdown { previewer = false })
      end, {
      desc =
      '[/] Fuzzily search in current buffer]'
    }, },
    { '<leader>ff', "<cmd>Telescope find_files<cr>", {
      desc =
      '[F]ind [F]iles'
    }, },
    { '<leader>fh', "<cmd>Telescope help_tags<cr>", {
      desc =
      '[F]ind [H]elp'
    }, },
    { '<leader>fw', "<cmd>Telescope grep_string<cr>", {
      desc =
      '[F]ind current [W]ord'
    }, },
    { '<leader>fg', "<cmd>Telescope live_grep<cr>", {
      desc =
      '[F]ind by [G]rep'
    }, },
    { '<leader>fd', "<cmd>Telescope diagnostics<cr>", {
      desc =
      '[F]ind [D]iagnostics'
    } },
  },
  config = function()
    local actions = require "telescope.actions"
    require("telescope").setup {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },

        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,

            ["<C-c>"] = actions.close,

            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

            ["<CR>"] = actions.select_default,

            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
          },

          n = {
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default,

            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,

            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,

            ["?"] = actions.which_key,
          },
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')

    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { desc = "[G]oto [R]eferences" })
  end
}
