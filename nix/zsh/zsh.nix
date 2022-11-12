{config, pkgs, ...}:
{
  programs.zsh.enable = true;
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.initExtraFirst = "source \"${config.home.homeDirectory}/.config/zsh/.zshrc_personal\"";
  programs.zsh.history.path = "\$ZDOTDIR/.zsh_history";
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
}
