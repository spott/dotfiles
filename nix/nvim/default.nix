{pkgs,...}: {
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
    basedpyright
    lua-language-server
    alejandra
    nil
    ruff
    fzf
  ];

  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua/bootstrap.lua".source = ./lua/bootstrap.lua;
  xdg.configFile."nvim/lua/lsp.lua".source = ./lua/lsp.lua;

  home.packages = with pkgs; [
    # nvim stuff
    tree-sitter
    vscode-langservers-extracted
    terraform-lsp
    #nixd
    efm-langserver
    basedpyright
    lua-language-server
    alejandra
    nil
    ruff
  ];
}
