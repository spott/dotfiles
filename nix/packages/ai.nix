{pkgs,...}: {
  home.packages = with pkgs; [
    # AI stuff
    unstable.codex
    unstable.gemini-cli
    unstable.qwen-code
    #unstable.opencode
  ];
}
