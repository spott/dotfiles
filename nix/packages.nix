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

    # rust stuff
    rustup
    dprint
    rustc

    # python development
    ruff
    rye
    uv
    pipenv

    # data stuff
    stable.parquet-tools
    sq # jq for structured data like csvs or sqlite databases
    csvlens 
    sqlite

    # network tools:
    tcping-go
    inetutils #telnet et al
    mtr-gui # network diag tool
    bandwhich # bandwidth by process

    # web dev
    httpie
    xh # httpie rewrite in rust

    # nix developmentt
    alejandra
    devbox
    cachix

    # AI stuff
    ollama
    oterm
    aichat
    llama-cpp
    claude-code

    # development
    git
    git-lfs
    jujutsu
    dblab
    just
    gh-dash # tui for github cli
    cmake

    # cloud
    awscli2 #<- This was annoying and broke all help text
    localstack

    # keep nix commands up to date (if only within the home manager environment:
    nix

    # pdf utils
    poppler

    # json
    fx # tui for json
    yq # jq replacement for yaml files and xml files as well
    jq # because yq doc for jq sucks, and having it isn't costly
    jnv # interactive json filter using jq
    jqp # tui for jq

    # docker:
    oxker # docker tui
    lazydocker

    # disk space
    dua # disk space monitor tool
    gdu # disk space monitor tool
    ncdu # disk space usage

    # Download:
    stable.monolith # singlepage downloader for web pages.

    # accounting:
    hledger # accounting software
    hledger-ui # ui for accounting software

    # string manipulation
    sttr # for string transformations
    sd # sed replacement...
    grex # regex generation tool

    # meta:
    halp # help for commands...

    viddy # modern watch replacement
    watchman # watch filesystem objects and do things when they change.

    # From terminaltrove:
    age # file encryption tool
    buku # bookmarking tool
    calcurse # terminal calender
    dijo # habit tracker
    glow # markdown renderer
    hyperfine # benchmark tool
    navi # interactive cheatsheet tool
    rizin # reverse engineering framework
    lemmeknow # file info tool?
    wtfutil # personal information dashboard for the terminal
    ouch # for compressing/decompressing
    
    kalker # scientific calculator
    stable.numbat # scientific calculator with units
  ];

}
