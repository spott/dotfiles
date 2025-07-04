{
  config,
  lib,
  ...
}: {
  programs.zsh.enable = true;
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.initContent = lib.mkBefore "source \"${config.home.homeDirectory}/.config/zsh/.zshrc_personal\"";
  programs.zsh.history.path = "\$ZDOTDIR/.zsh_history";
  programs.zsh.history.extended = true;
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.history.ignoreDups = false;
  programs.zsh.history.ignoreSpace = true;
  programs.zsh.history.save = 1000000000;
  programs.zsh.history.size = 2000000000;
  programs.zsh.enableVteIntegration = true;
  programs.zsh.defaultKeymap = "viins";
  programs.zsh.enableCompletion = false;

  programs.zsh.shellAliases = {
    cat = "bat";
    diff = "delta";
    df = "duf";
    dig = "dog";
    find = "fd";
    top = "btm";
    grep = "rg";
    vim = "nvim";
  };

  xdg.configFile."zsh/.zshrc_personal".source = ./zshrc_personal;
  xdg.configFile."zsh/.zimrc".source = ./zimrc;
  xdg.configFile."zsh/.zprofile".source = ./zprofile;

  # some of these need to be behind options:
  programs.zsh.dirHashes = {
    code = "$HOME/code";
    hl = "$HOME/Homelab";
    nix = "$HOME/.dotfiles/nix";
    docs = "$HOME/Documents";
    envs = "$HOME/environments";
  };
}
