{
  ...
}: {
  imports = [
    ./nix/direnv.nix
    ./nix/git.nix
    ./nix/fzf.nix
    ./nix/bat.nix
    ./nix/tmux.nix
    ./nix/ssh.nix
    ./nvim
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #
  # bottom (btm command, top replacement)
  #
  # programs.bottom.enable = true;
  # see https://github.com/ClementTsang/bottom/blob/master/sample_configs/default_config.toml for possiblities
  #programs.bottom.settings

  #
  # aria2  (https://aria2.github.io, multi-protocol download utility
  # 
  # programs.aria2.enable = true;

  #
  # poetry
  #
  # programs.poetry.enable = true;
  # programs.poetry.settings = {
  #   virtualenvs.in-project = true;
  #   virtualenvs.prefer-active-python = true;
  #   virtualenvs.options.always-copy = true;
  # };
}
