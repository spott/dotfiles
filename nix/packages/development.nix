{pkgs,...}: {
  home.packages = with pkgs; [
    # rust stuff
    rustup
    dprint
    rustc

    # python:
    unstable.uv
    pipenv
    python312Full
    unstable.ruff
    
    # dev
    #jujutsu
    gh-dash # tui for github cli
  ];
}
