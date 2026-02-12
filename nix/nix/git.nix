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
  programs.git.ignores = [ ".zsh_history" ];
  programs.git.settings = {
    user.name = "Andrew Spott";
    user.email = "andrew.spott@gmail.com";
    init.defaultBranch = "main";
    push.autosetupRemote = true;
    merge.conflictstyle = "diff3";
    diff.colorMoved = "default";
  };
  programs.git.lfs.enable = true;
  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;
  programs.delta.options = {
    navigate = true;
    light = false;
  };

}
