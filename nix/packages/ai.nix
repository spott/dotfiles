{pkgs,...}: {
  home.packages = with pkgs; [
    # AI stuff
    unstable.claude-code
    unstable.codex
    unstable.gemini-cli
    unstable.qwen-code
    #unstable.opencode
  ];
}
