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
    eza # exa is unmaintained now...
    sd # sed replacement
    tldr # examples for commands
    mosh # ssh replacement
    yq # jq replacement for yaml files and xml files as well
    jq # because yq doc for jq sucks, and having it isn't costly
    diffoscopeMinimal # to allow diffing of directories
    viu # an image viewer for the terminal
    fastfetch # system info + pretty picture (has a home-manager module)
    highlight # for syntax highlighting

    # nvim stuff
    tree-sitter
    vscode-langservers-extracted
    terraform-lsp
    nixd
    efm-langserver
    #pyright # depreciated in favor of basedpyright
    basedpyright
    lua-language-server
    nil

    # python development
    ruff
    pipenv
    (python311Full.withPackages(ps: [ps.pipx]))
    stable.parquet-tools

    # nix developmentt
    alejandra
    devbox

    # development
    git
    dblab

    # cloud
    awscli2 #<- This was annoying and broke all help text

    # keep nix commands up to date (if only within the home manager environment:
    nix

    # utils
    inetutils #telnet et al

    # From terminaltrove:
    atac # postman replacement for the terminal
    age # file encryption tool
    buku # bookmarking tool
    csvlens 
    calcurse # terminal calender
    dijo # habit tracker
    dua # disk space monitor tool
    gdu # disk space monitor tool
    fx # tui for json
    glow # markdown renderer
    gh-dash # tui for github cli
    hledger # accounting software
    hledger-ui # ui for accounting software
    halp # help for commands...
    hyperfine # benchmark tool
    jnv # interactive json filter using jq
    jqp # tui for jq
    lazydocker
    kalker # scientific calculator
    mtr-gui # network diag tool
    navi # interactive cheatsheet tool
    ncdu # disk space usage
    rizin # reverse engineering framework
    sttr # for string transformations
    sd # sed replacement...
    diskonaut # disk space 
    grex # regex generation tool
    lemmeknow # file info tool?
    wtf # personal information dashboard for the terminal
    viddy # modern watch replacement
    oxker # docker tui
    numbat # scientific calculator with units
    ouch # for compressing/decompressing
    bandwhich # bandwidth by process
  ];

  dirHashes = {
    nix = "$HOME/.dotfiles/nix";
    docs = "$HOME/Documents";
    envs = "$HOME/environments";
  };
}
