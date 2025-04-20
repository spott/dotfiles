{...}: {
  #
  # gh (github commandline)
  #
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";

  #
  # git
  #
  #xdg.configFile."git/config".source = ./git/config;
  programs.git.enable = true;
  programs.git.userName = "Andrew Spott";
  programs.git.userEmail = "andrew.spott@gmail.com";
  programs.git.delta.enable = true;
  programs.git.delta.options = {
    navigate = true;
    light = false;
  };
  programs.git.ignores = [ ".zsh_history" ];
  programs.git.extraConfig = {
    init.defaultBranch = "main";
    push.autosetupRemote = true;
    merge.conflictstyle = "diff3";
    diff.colorMoved = "default";
  };

}
