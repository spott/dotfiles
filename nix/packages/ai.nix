{
  config,
  lib,
  pkgs,
  ...
}: {
  # Which codex build to install. nixpkgs' `codex` lags upstream by weeks;
  # configurations that evaluate against this flake's own pkgs get the
  # codex-cli-nix overlay's package through the same name, while an external
  # consumer (iac's orchard workspace image, which uses its own nixpkgs) sets
  # this to the flake input's package explicitly — see homeManagerModules.devbox.
  options.dotfiles.ai.codexPackage = lib.mkOption {
    type = lib.types.package;
    default = pkgs.codex;
    description = "The codex CLI package to install.";
  };

  config.home.packages = with pkgs; [
    # AI stuff
    config.dotfiles.ai.codexPackage
    # gemini-cli dropped: nixpkgs marks it for removal upstream — Google
    # transitioned Gemini CLI to Antigravity CLI, so it emits a removal
    # warning now and will break outright on a later bump. Unused anyway.
    unstable.qwen-code
    # herdr (the TUI multiplexer) dropped 2026-11-08: orchard workspaces run
    # herdr-core (`hc`) as a headless service instead (iac orchard/image).
    #unstable.opencode
  ];
}
