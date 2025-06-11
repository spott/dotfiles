{pkgs,...}: {
  home.packages = with pkgs; [
    # AI stuff
    claude-code
    codex
  ];
}
