{...}: {
  imports = [
    ./packages/docker.nix
    ./packages/iac.nix
    ./packages/shell.nix
    ./packages/extra.nix
    ./packages/development.nix
    ./packages/ai.nix
    ./packages/gui.nix
    ./packages/images.nix

    ./nix/direnv.nix
    ./nix/git.nix
    ./nix/fzf.nix
    ./nix/bat.nix
    ./nix/tmux.nix
    ./nix/ssh.nix
    ./nvim

    ./1Password
    ./ghostty

    ./zsh
    ./nix/vscode.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
