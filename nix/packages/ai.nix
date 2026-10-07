{pkgs,...}: {
  home.packages = with pkgs; [
    # AI stuff
    codex
    # gemini-cli dropped: nixpkgs marks it for removal upstream — Google
    # transitioned Gemini CLI to Antigravity CLI, so it emits a removal
    # warning now and will break outright on a later bump. Unused anyway.
    unstable.qwen-code
    unstable.herdr
    #unstable.opencode
  ];
}
