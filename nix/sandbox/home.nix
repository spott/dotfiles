{ config, lib, pkgs, ... }:

let
  cfg = config.sandbox;
in {
  options.sandbox = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Sandbox name (username will be sandbox-<name>)";
    };
  };

  config = {
    home.username = "sandbox-${cfg.name}";
    home.homeDirectory = "/Users/sandbox-${cfg.name}";

    home.sessionVariables = {
      SHARED_WORKSPACE = "/Users/Shared/sandbox-${cfg.name}";
    };

    home.stateVersion = "24.11";
    programs.home-manager.enable = true;
    #dotfiles._1password.sshAgentConfig = true;
  };

  imports = [
    ../packages/shell.nix
    ../packages/development.nix
    ../packages/ai.nix

    ../nix/direnv.nix
    ../nix/git.nix
    ../nix/fzf.nix
    ../nix/tmux.nix
    ../nix/ssh.nix
    ../nvim
    ../zsh
    #../1Password
  ];
}
