require "paq" {
  "savq/paq-nvim";

  "kylechui/nvim-surround";
  "numToStr/Comment.nvim";
  
  "fladson/vim-kitty";

  "kyazdani42/nvim-web-devicons";
  "nvim-lualine/lualine.nvim";
  "Mofiqul/dracula.nvim";
  "neovim/nvim-lspconfig";
  "hrsh7th/nvim-cmp";
  "epwalsh/obsidian.nvim";
  "nvim-lua/plenary.nvim";
  {"nvim-telescope/telescope.nvim", branch='0.1.x'};
  {'nvim-telescope/telescope-fzf-native.nvim', run='make'};
  -- "junegunn/fzf";
  -- "ibhagwan/fzf-lua";
  {"nvim-treesitter/nvim-treesitter", run='TSUpdate'};

}

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

require'lspconfig'.rnix.setup{}
require'lspconfig'.pyright.setup{}

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

require('obsidian').setup {
    dir = "~/Documents/Notes/Personal/",
    completion = {
        nvim_cmp = true,
    }
}

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
  }),
})

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

vim.g.mapleader = ','


