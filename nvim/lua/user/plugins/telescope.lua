local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require "telescope.config".values

local globgrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end
      local pieces = vim.split(prompt, "  ") -- two spaces
      local args = { "rg" }                  -- use ripgrep
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end
      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end
      ---@diagnostic disable-next-line: deprecated
      return vim.tbl_flatten {
        args, { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd
  }
  pickers.new(opts, {
    debounce = 100,
    prompt_title = "Live Glob Grep",
    finder = finder,
    previewer = conf.grep_previewer(opts),
    sorter = require('telescope.sorters').empty(),
  }):find()
end

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
  branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim', {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },
    -- replaces the code actions with telescope menu
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
  },
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
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          previewer = false })
      end, { desc = '[🔭]: search in current buffer]'
    }, },
    { '<leader>fo',
      function()
        require('telescope.builtin').live_grep(
          require('telescope.themes').get_dropdown({
            grep_open_files = true,
            prompt_title = 'Live Grep - Open Buffers',
          })
        )
      end, { desc = '[🔭]: [f]ind [g]repped references of a word in open buffers'
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
    { '<leader>fg', function()
      globgrep()
    end, {
      desc = '[🔭]: [f]ind [g]repped references of a word'
    }, },
    { '<leader>fs', "<cmd>Telescope git_status<cr>", {
      desc =
      '[🔭]: [f]ind the current git [s]tatus'
    }, },
    { '<leader>fr',
      function()
        require('telescope.builtin').lsp_references(require('telescope.themes').get_dropdown({ include_current_line = true, show_line = false }))
      end, {
      desc =
      '[🔭]: [f]ind LSP [r]eferences of a word'
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
      defaults = { path_display = { "smart" }, mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,

          ["<C-c>"] = actions.close,

          ["<Down>"] = actions.move_selection_next,
          ["<Up>"] = actions.move_selection_previous,

          ["<CR>"] = select_one_or_multi,

          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,

          ["<C-v>"] = actions.select_vertical,
          ["<C-s>"] = actions.select_horizontal,

          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,

          ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
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

          ["v"] = actions.select_vertical,
          ["s"] = actions.select_horizontal,

          ["q"] = actions.send_to_qflist + actions.open_qflist,

          ["?"] = actions.which_key,
        },
      },
      },
      pickers = {
        buffers = {
          sort_lastused = true,
          theme = "dropdown",
          mappings = {
            i = { ["<c-x>"] = actions.delete_buffer },
            n = { ["x"] = actions.delete_buffer }
          }
        }
      },
      extensions = { ["ui-select"] = { require("telescope.themes").get_cursor() }
      }
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    vim.keymap.set('n', 'gs', require('telescope.builtin').lsp_document_symbols,
      { desc = "[🔭]: [f]ind document [s]ymbols" })
  end
}
