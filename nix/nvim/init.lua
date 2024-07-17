require "paq" {
  "savq/paq-nvim",

  "kylechui/nvim-surround",
  "numToStr/Comment.nvim",

  { "fladson/vim-kitty",                          opt = true },

  { "kyazdani42/nvim-web-devicons",               opt = true },
  { "nvim-lualine/lualine.nvim",                  opt = true },
  { "Mofiqul/dracula.nvim",                       opt = true },

  { "neovim/nvim-lspconfig",                      opt = true },

  { "FelipeLema/cmp-async-path",                  opt = true },
  { "hrsh7th/cmp-nvim-lsp",                       opt = true },
  { "hrsh7th/nvim-cmp",                           opt = true },

  { "epwalsh/obsidian.nvim",                      opt = true },

  { "nvim-lua/plenary.nvim",                      opt = true },
  { "nvim-telescope/telescope.nvim",              branch = '0.1.x',                   opt = true },
  { 'nvim-telescope/telescope-fzf-native.nvim',   build = 'make',                     opt = true },

  { "nvim-treesitter/nvim-treesitter",            build = ':TSUpdate' },
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  { "JoosepAlviste/nvim-ts-context-commentstring" },

  { 'creativenull/efmls-configs-nvim' },

  { "knubie/vim-kitty-navigator",                 build = 'cp ./*.py ~/.config/kitty/', opt = true },
}

vim.g.mapleader = ','

-- treesitter config
require('nvim-treesitter.configs').setup {
  ensure_installed = { "python", "nix", "lua", "rust", "julia", "bash", "yaml",
    "markdown", "markdown_inline", "html", "css", "comment",
    "json", "json5", "sql", "toml", "terraform", "vim",
    "latex", "hcl", "go", "dockerfile", "csv" },

  sync_install = false,

  auto_install = true,

  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = { query = "@function.outer", desc = "select the entire function including sig and declaration" },
        ["if"] = { query = "@function.inner", desc = "select the inner part of a function (excluding sig and declaration)" },
        ["ac"] = { query = "@class.outer", desc = "select the whole class region" },
        ["ic"] = { query = "@class.inner", desc = "select the inner part of the class region" },
        ["as"] = { query = "@scope", query_group = "locals", desc = "select language scope" },
      },
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },

      include_surrounding_whitespace = true,
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = { query = "@function.outer", desc = "after the function" },
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        --
        -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
        -- ["]o"] = { query = "@loop.*", desc = "next,
        -- -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
        --
        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
      -- Below will go to either the start or the end, whichever is closer.
      -- Use if you want more granular movements
      -- Make it even more gradual by adding multiple queries and regex.
      -- goto_next = {
      --   ["]d"] = "@conditional.outer",
      -- },
      -- goto_previous = {
      --   ["[d"] = "@conditional.outer",
      -- }
    },

  }
}


-- fold using nvim treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 --this makes the folds not show up initially

-- search stuff
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.inccommand = "split"

-- tab stuff
vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
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
    packadd vim-kitty
    packadd vim-kitty-navigator
    packadd dracula.nvim
    packadd lualine.nvim
    packadd nvim-cmp
    packadd nvim-web-devicons
    packadd obsidian.nvim
    packadd plenary.nvim
    packadd telescope.nvim
    packadd telescope-fzf-native.nvim
    packadd cmp-async-path
    packadd cmp-nvim-lsp
  ]]

  require('telescope').setup {
    extensions = {
      fzf = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      }
    }
  }
  require('telescope').load_extension('fzf')

  -- telescope keybindings
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

  --theme:
  vim.cmd [[colorscheme dracula]]
  require("dracula").setup({
    show_end_of_buffer = true,
    transparent_bg = true,
    italic_comment = true
  })

  --lualine
  require('lualine').setup {
    options = {
      theme = 'dracula-nvim'
    }
  }

  require('obsidian').setup {
    dir = "~/ObsidianNotes/Personal/",
    completion = {
      nvim_cmp = true,
    }
  }

  vim.o.completeopt = "menuone,noinsert,noselect"

  local cmp = require 'cmp'

  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'async_path' }
    }),
  })

  require('lsp') -- in lua/lsp.lua
  -- vim-kitty-navigator
  if os.getenv("TERM") == "xterm-kitty" then
    vim.g.kitty_navigator_no_mappings = 1
    vim.g.tmux_navigator_no_mappings = 1

    vim.keymap.set('n', '<C-w>h', ':KittyNavigateLeft<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-w>j', ':KittyNavigateDown<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-w>k', ':KittyNavigateUp<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-w>l', ':KittyNavigateRight<CR>', { noremap = true, silent = true })
  end
end
