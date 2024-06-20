require "paq" {
  "savq/paq-nvim";

  "kylechui/nvim-surround";
  "numToStr/Comment.nvim";
  
  {"fladson/vim-kitty", opt=true};

  {"kyazdani42/nvim-web-devicons", opt=true};
  {"nvim-lualine/lualine.nvim", opt=true};
  {"Mofiqul/dracula.nvim", opt=true};

  {"neovim/nvim-lspconfig", opt=true};

  {"FelipeLema/cmp-async-path", opt=true};
  {"hrsh7th/cmp-nvim-lsp", opt=true};
  {"hrsh7th/nvim-cmp", opt=true};

  {"epwalsh/obsidian.nvim", opt=true};

  {"nvim-lua/plenary.nvim", opt=true};
  {"nvim-telescope/telescope.nvim", branch='0.1.x', opt=true};
  {'nvim-telescope/telescope-fzf-native.nvim', build='make', opt=true};

  {"nvim-treesitter/nvim-treesitter", build=':TSUpdate'};

  {"knubie/vim-kitty-navigator", build='cp ./*.py ~/.config/kitty/', opt=true};
}

vim.g.mapleader = ','

-- treesitter config
require('nvim-treesitter.configs').setup {
  ensure_installed = { "python", "nix", "lua", "rust", "julia", "bash", "yaml", "markdown", "markdown_inline", "html", "css", "comment", "json", "json5", "sql", "toml"},

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
}
-- fold using nvim treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 --this makes the folds not show up initially

vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true

vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.opt.autoindent = true

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
  vim.cmd[[
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
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
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
  vim.cmd[[colorscheme dracula]]
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

  vim.o.completeopt="menuone,noinsert,noselect"

  local cmp = require'cmp'

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

      vim.api.nvim_set_keymap('n', 'C-h', ':KittyNavigateLeft <CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', 'C-j', ':KittyNavigateDown <CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', 'C-k', ':KittyNavigateUp <CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', 'C-l', ':KittyNavigateRight <CR>', { noremap = true, silent = true })
  end

end









