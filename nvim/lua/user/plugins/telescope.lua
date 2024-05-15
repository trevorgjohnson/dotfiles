-- Allows <cr> in telescope to select one under the cursor or multiple using <tab> (similar to fzf)
local select_one_or_multi = function(prompt_bufnr)
  local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require('telescope.actions').close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        vim.cmd(string.format('%s %s', 'edit', j.path))
      end
    end
  else
    require('telescope.actions').select_default(prompt_bufnr)
  end
end

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
    { '<leader>?', "<cmd>Telescope keymaps<cr>", {
      desc =
      '[🔭]: find available keymaps'
    }, },
    { '<leader><space>', "<cmd>Telescope buffers<cr>", {
      desc =
      '[🔭]: find existing buffers'
    }, },
    { '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes')
          .get_dropdown { previewer = false })
      end, {
      desc =
      '[🔭]: search in current buffer]'
    }, },
    { '<leader>ff', "<cmd>Telescope find_files<cr>", {
      desc =
      '[🔭]: [f]ind [f]iles'
    }, },
    { '<leader>fh', "<cmd>Telescope help_tags<cr>", {
      desc =
      '[🔭]: [f]ind [h]elp associated to Neovim'
    }, },
    { '<leader>fw', "<cmd>Telescope grep_string<cr>", {
      desc =
      '[🔭]: [f]ind references of a [w]ord under the cursor'
    }, },
    { '<leader>fg', "<cmd>Telescope live_grep<cr>", {
      desc =
      '[🔭]: [f]ind references of a word'
    }, },
    { '<leader>fc',
      function()
        require('telescope.builtin').find_files({ cwd = '~/.config/dotfiles', prompt_title = 'Find Files - Config' })
      end, {
      desc =
      '[🔭]: [f]ind references of a word in [c]onfig'
    }, },
    { '<leader>fd', "<cmd>Telescope diagnostics<cr>", {
      desc =
      '[🔭]: [f]ind [d]iagnostics'
    } },
  },
  config = function()
    local actions = require "telescope.actions"
    require("telescope").setup {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        multi_icon = " ",
        path_display = { "smart" },

        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,

            ["<C-c>"] = actions.close,

            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

            ["<CR>"] = select_one_or_multi,

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

    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references,
      { desc = "[🔭]: [g]o to [r]eferences of a word" })
  end
}
