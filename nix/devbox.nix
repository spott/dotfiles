{...}: {
  imports = [
    ./packages/shell.nix
    ./packages/development.nix

    ./nix/direnv.nix
    ./nix/git.nix
    ./nix/fzf.nix
    ./nix/bat.nix
    ./nix/tmux.nix
    ./nix/ssh.nix
    ./nix/ai.nix
    ./nvim
    ./zsh
  ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/home/spott";
}
