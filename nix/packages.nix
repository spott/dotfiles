{pkgs, ...}: {
  packages = with pkgs; [
    # shell
    delta # diff pager
    difftastic # diff engine
    bottom # top replacement
    du-dust # du replacement
    fd # find replacement
    ripgrep # grep replacement
    duf # df replacement
    dogdns # dig replacement
    lsd # ls replacement... I'm using exa, so this might not be necessary
    eza # exa is unmaintained now...
    sd # sed replacement
    tldr # examples for commands
    mosh # ssh replacement
    yq # jq replacement for yaml files and xml files as well
    jq # because yq doc for jq sucks, and having it isn't costly

    # nvim stuff
    tree-sitter
    # tree-sitter-grammars.tree-sitter-vim
    # tree-sitter-grammars.tree-sitter-yaml
    # tree-sitter-grammars.tree-sitter-toml
    # tree-sitter-grammars.tree-sitter-sql
    # tree-sitter-grammars.tree-sitter-rust
    # tree-sitter-grammars.tree-sitter-python
    # tree-sitter-grammars.tree-sitter-nix
    # tree-sitter-grammars.tree-sitter-markdown
    # tree-sitter-grammars.tree-sitter-markdown-inline
    # tree-sitter-grammars.tree-sitter-json
    # tree-sitter-grammars.tree-sitter-json5
    # tree-sitter-grammars.tree-sitter-dockerfile
    # tree-sitter-grammars.tree-sitter-lua
    # tree-sitter-grammars.tree-sitter-comment
    # tree-sitter-grammars.tree-sitter-bash

    # python development
    #python310Packages.poetry
    black
    prospector
    pyright
    poetry#.override {python = python310;})
    pipenv
    (python310Full.withPackages(ps: [ps.pipx]))

    # nix developmentt
    alejandra
    rnix-lsp
    devbox

    # jdk needed for moneta terminal
    #zulu8
    #zulu
  ];

  dirHashes = {
    nix = "$HOME/.dotfiles/nix";
    docs = "$HOME/Documents";
    envs = "$HOME/environments";
  };
}
