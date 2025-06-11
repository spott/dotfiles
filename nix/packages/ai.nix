{pkgs,...}: {
  home.packages = with pkgs; [
    # AI stuff
    unstable.claude-code
    unstable.codex
  ];
}
