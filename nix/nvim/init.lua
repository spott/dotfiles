vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({'n', 'v'}, '<Space>', '<Nop>', {silent = true})
vim.o.timeoutlen = 500

-- keep screenposition when splitting
vim.opt.splitkeep = "screen"

if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

-- a few emacs-like keybindings
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-f>', '<C-o>l', { noremap = true, silent = true })
vim.keymap.set('i', '<C-b>', '<C-o>h', { noremap = true, silent = true })

-- enable diff vs. original file
-- after importing a file using R, run :DiffOrig to get the diff from the original file.
vim.cmd([[
  command! DiffOrig vert new | setlocal buftype=nofile | read ++edit # | 0d_
        \ | diffthis | wincmd p | diffthis
]])


-- ==========================================================================
-- Treesitter (main branch)
-- ==========================================================================
-- The new nvim-treesitter main branch does not use require('nvim-treesitter.configs').setup.
-- Highlighting, folding, and indentation are enabled via Neovim's native APIs.
-- Parsers are installed by Nix via withAllGrammars, so no :TSInstall needed.

-- Enable treesitter highlighting for all filetypes with a parser
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_start', { clear = true }),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
    -- experimental treesitter-based indentation (replaces indent = { enable = true })
    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- fold using treesitter (now via Neovim core)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- folds don't show up initially


-- ==========================================================================
-- Treesitter textobjects (main branch)
-- ==========================================================================
-- The textobjects plugin is now standalone — no longer nested inside
-- nvim-treesitter.configs. Keymaps must be set explicitly.

require("nvim-treesitter-textobjects").setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v',  -- charwise
      ['@function.outer'] = 'V',   -- linewise
      ['@class.outer'] = 'V',      -- linewise
    },
    include_surrounding_whitespace = true,
  },
  move = {
    set_jumps = true,
  },
}

-- Select keymaps
local ts_select = require("nvim-treesitter-textobjects.select")
vim.keymap.set({ "x", "o" }, "af", function()
  ts_select.select_textobject("@function.outer", "textobjects")
end, { desc = "select the entire function including sig and declaration" })
vim.keymap.set({ "x", "o" }, "if", function()
  ts_select.select_textobject("@function.inner", "textobjects")
end, { desc = "select the inner part of a function" })
vim.keymap.set({ "x", "o" }, "ac", function()
  ts_select.select_textobject("@class.outer", "textobjects")
end, { desc = "select the whole class region" })
vim.keymap.set({ "x", "o" }, "ic", function()
  ts_select.select_textobject("@class.inner", "textobjects")
end, { desc = "select the inner part of the class region" })
vim.keymap.set({ "x", "o" }, "as", function()
  ts_select.select_textobject("@scope", "locals")
end, { desc = "select language scope" })

-- Move keymaps
local ts_move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "]m", function()
  ts_move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })
vim.keymap.set({ "n", "x", "o" }, "]M", function()
  ts_move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })
vim.keymap.set({ "n", "x", "o" }, "]]", function()
  ts_move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })
vim.keymap.set({ "n", "x", "o" }, "][", function()
  ts_move.goto_next_end("@class.outer", "textobjects")
end, { desc = "Next class end" })
vim.keymap.set({ "n", "x", "o" }, "[m", function()
  ts_move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Prev function start" })
vim.keymap.set({ "n", "x", "o" }, "[M", function()
  ts_move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Prev function end" })
vim.keymap.set({ "n", "x", "o" }, "[[", function()
  ts_move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Prev class start" })
vim.keymap.set({ "n", "x", "o" }, "[]", function()
  ts_move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "Prev class end" })
vim.keymap.set({ "n", "x", "o" }, "]s", function()
  ts_move.goto_next_start("@scope", "locals")
end, { desc = "Next scope" })
vim.keymap.set({ "n", "x", "o" }, "]z", function()
  ts_move.goto_next_start("@fold", "folds")
end, { desc = "Next fold" })

-- Swap keymaps
local ts_swap = require("nvim-treesitter-textobjects.swap")
vim.keymap.set("n", "<leader>a", function()
  ts_swap.swap_next("@parameter.inner", "textobjects")
end, { desc = "Swap with next parameter" })
vim.keymap.set("n", "<leader>A", function()
  ts_swap.swap_previous("@parameter.inner", "textobjects")
end, { desc = "Swap with previous parameter" })

-- NOTE: incremental_selection (gnn/grn/grc/grm) was removed in the rewrite.
-- Textobjects (af/if/ac/ic above) serve a similar purpose.
-- If you miss it, consider https://github.com/sustech-data/wildfire.nvim


-- ==========================================================================
-- Search stuff
-- ==========================================================================
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.inccommand = "split"

-- tab stuff
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.autoindent = true

-- for : commands
vim.opt.wildmode = "list:longest,list:full"
vim.opt.wildignore:append({"*.pyc",".DS_Store",".git"})

-- undo
vim.opt.undofile = true


require('nvim-surround').setup()

require('Comment').setup {
  ---Add a space b/w comment and the line
  padding = true,
  ---Whether the cursor should stay at its position
  sticky = true,
  ---Lines to be ignored while (un)comment
  ignore = '^\\s*$',
  ---LHS of toggle mappings in NORMAL mode
  toggler = {
    ---Line-comment toggle keymap
    line = 'gcc',
    ---Block-comment toggle keymap
    block = 'gbc',
  },
  ---LHS of operator-pending mappings in NORMAL and VISUAL mode
  opleader = {
    ---Line-comment keymap
    line = 'gc',
    ---Block-comment keymap
    block = 'gb',
  },
  ---LHS of extra mappings
  extra = {
    ---Add comment on the line above
    above = 'gcO',
    ---Add comment on the line below
    below = 'gco',
    ---Add comment at the end of line
    eol = 'gcA',
  },
  ---Enable keybindings
  ---NOTE: If given `false` then the plugin won't create any mappings
  mappings = {
    ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
    basic = true,
    ---Extra mapping; `gco`, `gcO`, `gcA`
    extra = true,
  },
  ---Function to call before (un)comment
  pre_hook = nil,
  ---Function to call after (un)comment
  post_hook = nil,
}

if not vim.g.vscode then

  vim.cmd [[
    packadd nvim-lspconfig
    packadd flexoki
    packadd lualine.nvim
    packadd nvim-cmp
    packadd nvim-web-devicons
    packadd plenary.nvim
    packadd telescope.nvim
    packadd telescope-fzf-native.nvim
    packadd cmp-async-path
    packadd cmp-nvim-lsp

    packadd nvim-dap
    packadd nvim-dap-python
    packadd nvim-dap-ui
    packadd nvim-dap-virtual-text
    packadd nvim-nio

    packadd triptych.nvim

    packadd neotest
    packadd neotest-python

  ]]

  require("flexoki").setup({
    variant = "auto", -- auto, moon, or dawn
    dim_inactive_windows = true,
    extend_background_behind_borders = true,

    enable = {
        terminal = true,
    },

    styles = {
        bold = true,
        italic = false,
    },

    highlight_groups = {
        Comment = { fg = "subtle", italic = true },
    },
  })

  require('telescope').load_extension('lazygit')
  vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { desc = 'Open LazyGit' })

  require('statusline') -- in lua/statusline.lua

  vim.cmd [[colorscheme flexoki]]


  require('telescope').setup {
    extensions = {
      fzf = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      },
    }
  }
  require('telescope').load_extension('fzf')

  -- telescope keybindings
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
  vim.keymap.set('n', '<leader>bb', builtin.builtin, {})
  vim.keymap.set('n', '<leader>km', builtin.keymaps, {})
  vim.keymap.set('n', '<leader>kk', builtin.commands, {})
  vim.keymap.set('n', '<leader>lt', builtin.treesitter, {})

  vim.keymap.set('n', '<leader>gs', builtin.git_status, {})

  vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { silent = true, desc = 'Next buffer' })
  vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { silent = true, desc = 'Previous buffer' })

  vim.o.completeopt = "menuone,noinsert,noselect"

  local cmp = require 'cmp'

  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'async_path' }
    }),
  })

  require('triptych').setup({})
  vim.keymap.set('n', '<leader>ft', ':Triptych<CR>', { silent = true, desc = 'Toggle Triptych' })

  require('lsp') -- in lua/lsp.lua
  require('ai') -- in lua/ai.lua
  require('dap_config') -- in lua/dap_config.lua
  require('tests') -- in lua/tests.lua

end
