{pkgs, ...}: {
  #
  # neovim
  #
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.withNodeJs = true;
  programs.neovim.withPython3 = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.extraPackages = with pkgs; [
    tree-sitter
    vscode-langservers-extracted
    terraform-lsp
    efm-langserver
    unstable.basedpyright
    lua-language-server
    alejandra
    nil
    unstable.ruff
    fzf
    unstable.ty
  ];

  programs.neovim.plugins = with pkgs.unstable.vimPlugins; [
    telescope-fzf-native-nvim
    telescope-nvim
    nvim-surround
    nvim-web-devicons
    lualine-nvim
    nvim-lspconfig
    cmp-async-path
    cmp-nvim-lsp
    nvim-cmp
    obsidian-nvim
    plenary-nvim
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-ts-context-commentstring
    efmls-configs-nvim
    comment-nvim

    (pkgs.vimUtils.buildVimPlugin
      {
        pname = "flexoki-nvim";
        version = "079554c242a86be5d1a95598c7c6368d6eedd7a3";
        src = pkgs.fetchFromGitHub {
          owner = "nuvic";
          repo = "flexoki-nvim";
          rev = "079554c242a86be5d1a95598c7c6368d6eedd7a3";
          sha256 = "vjjAulQVFS+OmpWzLkliqpan3GXlvatdaCnI96bjxC0=";
        };
      })
  ];

  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua/bootstrap.lua".source = ./lua/bootstrap.lua;
  xdg.configFile."nvim/lua/lsp.lua".source = ./lua/lsp.lua;
}
