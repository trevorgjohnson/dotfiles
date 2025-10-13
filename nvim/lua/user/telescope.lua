---commend Adds the glob grep picker to the global telescope pickers
---@param opts {cwd: string; pickers: any; finders: any; make_entry: any; conf:any}
local globgrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  opts.pickers.new(opts, {
    debounce = 100,
    prompt_title = "Live Glob Grep",
    finder = opts.finders.new_async_job {
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
      entry_maker = opts.make_entry.gen_from_vimgrep(opts),
      cwd = opts.cwd
    },
    previewer = opts.conf.grep_previewer(opts),
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
  event = 'VimEnter',
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
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes')
          .get_dropdown {
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
    { '<leader>fk', require('telescope.builtin').marks, { desc = '[🔭]: find mar[k] within the list of marks' }, },
    { '<leader>fl', require('telescope.builtin').loclist, { desc = '[🔭]: find [l]oc within the loclist' }, },
    { '<leader>fj', require('telescope.builtin').jumplist, { desc = '[🔭]: find [j]ump within the jumplist' }, },
    { '<leader>fc', require('telescope.builtin').command_history, { desc = '[🔭]: find [c]ommand within the command history' }, },
    { '<leader>fw', "<cmd>Telescope grep_string<cr>", {
      desc =
      '[🔭]: [f]ind references of a [w]ord under the cursor'
    }, },
    { '<leader>fg', function()
      globgrep({
        pickers = require("telescope.pickers"),
        finders = require("telescope.finders"),
        make_entry = require("telescope.make_entry"),
        conf = require("telescope.config").values
      })
    end, {
      desc = '[🔭]: [f]ind [g]repped references of a word'
    }, },
    { '<leader>fs', "<cmd>Telescope git_status<cr>", {
      desc =
      '[🔭]: [f]ind the current git [s]tatus'
    }, },
    { '<leader>fc',
      function()
        require('telescope.builtin').find_files({
          cwd = '~/.config/dotfiles',
          prompt_title =
          'Find Files - Config'
        })
      end, {
      desc =
      '[🔭]: [f]ind references of a word in [c]onfig'
    }, },
    { '<leader>fd', "<cmd>Telescope diagnostics<cr>", {
      desc =
      '[🔭]: [f]ind [d]iagnostics'
    } },
    { 'grr', require('telescope.builtin').lsp_references, { desc = '[🔭]: find LSP [r]efe[r]ences of a word' }, },
    { 'grd', require('telescope.builtin').lsp_definitions, { desc = '[🔭]: find LSP [d]efinitions of a word' }, },
    { 'gri', require('telescope.builtin').lsp_implementations, { desc = '[🔭]: find LSP [i]mplementations of a word' }, },
    { 'gtd', require('telescope.builtin').lsp_type_definitions, { desc = '[🔭]: find LSP [t]ype [d]efinitions of a word' }, },
    { 'gO', require('telescope.builtin').lsp_document_symbols, { desc = '[🔭]: find LSP document symb[O]ls' }, },
  },
  config = function()
    local actions = require "telescope.actions"

    require("telescope").setup {
      defaults = { path_display = { "smart" }, mappings = {
        i = {
          ["<CR>"] = select_one_or_multi,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
        }, },
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
  end
}
