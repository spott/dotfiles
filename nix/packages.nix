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
    diffoscopeMinimal # to allow diffing of directories

    # nvim stuff
    tree-sitter
    vscode-langservers-extracted

    # python development
    #python310Packages.poetry
    #black
    #prospector
    ruff
    #pyright
    poetry#.override {python = python310;})
    pipenv
    #pipx
    (python311Full.withPackages(ps: [ps.pipx]))

    # nix developmentt
    alejandra
    rnix-lsp
    devbox

    # development
    git

    # cloud
    awscli2 #<- This was annoying and broke all help text

    # keep nix commands up to date (if only within the home manager environment:
    nix
  ];

  dirHashes = {
    nix = "$HOME/.dotfiles/nix";
    docs = "$HOME/Documents";
    envs = "$HOME/environments";
  };
}
