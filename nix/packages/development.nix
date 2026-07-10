{pkgs,...}: {
  home.packages = with pkgs; [
    # rust stuff
    rustup
    dprint
    rustc

    # python:
    unstable.uv
    pipenv
    python312
    unstable.ruff
    unstable.ty
    unstable.pyrefly
    
    # dev
    unstable.jujutsu
    gh-dash # tui for github cli
    lazygit # tui for git
    tuicr # tui for per-commit review

    # lines of code:
    cloc
  ];
}
