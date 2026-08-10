{...}: {
  #
  # fzf
  #
  programs.fzf.enable = true;
  # The declarative plugin loader initializes fzf once and adds the existing
  # fd/rg and preview customization from the former zimfw module.
  programs.fzf.enableZshIntegration = false;
  programs.fzf.colors = {
    fg="-1";
    bg="-1";
    hl="#5fff87";
    "fg+"="-1";
    "bg+"="-1";
    "hl+"="#ffaf5f";
    info="#af87ff";
    prompt="#5fff87";
    pointer="#ff87d7";
    marker="#ff87d7";
    spinner="#ff87d7";
  };

}
