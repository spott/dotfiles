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

    # python development
    ruff
    rye
    uv
    pipenv
    (python311Full.withPackages(ps: [ps.pipx]))

    # data stuff
    stable.parquet-tools
    sq # jq for structured data like csvs or sqlite databases

    # network tools:
    tcping-go
    inetutils #telnet et al
    mtr-gui # network diag tool

    # web dev
    httpie
    xh # httpie rewrite in rust

    # nix developmentt
    alejandra
    devbox

    # AI stuff
    ollama
    oterm
    aichat
    llama-cpp

    # development
    git
    git-lfs
    jujutsu
    dblab
    just
    gh-dash # tui for github cli

    # cloud
    awscli2 #<- This was annoying and broke all help text

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
    diskonaut # disk space 
    ncdu # disk space usage

    # From terminaltrove:
    age # file encryption tool
    buku # bookmarking tool
    csvlens 
    calcurse # terminal calender
    dijo # habit tracker
    glow # markdown renderer
    hledger # accounting software
    hledger-ui # ui for accounting software
    halp # help for commands...
    hyperfine # benchmark tool
    kalker # scientific calculator
    navi # interactive cheatsheet tool
    rizin # reverse engineering framework
    sttr # for string transformations
    sd # sed replacement...
    grex # regex generation tool
    lemmeknow # file info tool?
    wtf # personal information dashboard for the terminal
    viddy # modern watch replacement
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
