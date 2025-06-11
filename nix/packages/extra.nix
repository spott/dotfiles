{pkgs, ...}: {
  home.packages = with pkgs; [
    highlight
    tldr
    diffoscopeMinimal
    fastfetch

    # view images in the terminal:
    viu

    # data stuff
    parquet-tools
    sq # jq for structured data like csvs or sqlite databases
    csvlens 
    sqlite

    # network tools:
    tcping-go
    mtr-gui # network diag tool
    bandwhich # bandwidth by process

    dblab

    # pdf utils
    poppler

    # json
    fx # tui for json
    jnv # interactive json filter using jq
    jqp # tui for jq
    
    # disk space
    dua # disk space monitor tool
    gdu # disk space monitor tool
    ncdu # disk space usage

    # Download:
    #unstable.monolith # singlepage downloader for web pages.

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
    
    #kalker # scientific calculator
    #stable.numbat # scientific calculator with units

    # ai stuff
    unstable.ollama
    unstable.llama-cpp

    # compatability
    ncurses
  ];
}
