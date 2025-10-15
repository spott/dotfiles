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
    unstable.ty
    unstable.pyrefly
    
    # dev
    unstable.jujutsu
    gh-dash # tui for github cli

    # lines of code:
    cloc
  ];
}
