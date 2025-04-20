{pkgs,...}: {
  #
  # neovim
  #
  programs.neovim.enable = true;
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
