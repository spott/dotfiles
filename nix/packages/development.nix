{pkgs,...}: {
  home.packages = with pkgs; [
    # rust stuff
    rustup
    dprint
    rustc

    # python:
    uv
    pipenv
    python312Full
    ruff
    
    # dev
    #jujutsu
    gh-dash # tui for github cli
  ];
}
