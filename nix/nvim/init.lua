require "paq" {
  "savq/paq-nvim";

  "kylechui/nvim-surround";
  "b3nj5m1n/kommentary";

  "kyazdani42/nvim-web-devicons";
  "nvim-lualine/lualine.nvim";
  "Mofiqul/dracula.nvim";
  "neovim/nvim-lspconfig";
  "hrsh7th/nvim-cmp";
  "epwalsh/obsidian.nvim";
  -- "junegunn/fzf";
  {"nvim-treesitter/nvim-treesitter", run='TSUpdate'};

}

--theme:
vim.cmd[[colorscheme dracula]]
require("dracula").setup({
  show_end_of_buffer = true,
  transparent_bg = true,
  italic_comment = true
})

--lualine
require('lualine').setup()


require('nvim-surround').setup()
-- require('kommentary.config').use_extended_mappings()

-- treesitter config
require('nvim-treesitter.configs').setup {
  ensure_installed = { "python", "nix", "lua", "rust", "julia", "bash", "yaml", "markdown", "markdown_inline", "html", "css" },

  sync_install = false,

  auto_install = true,

  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  }
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

vim.g.mapleader = ','


