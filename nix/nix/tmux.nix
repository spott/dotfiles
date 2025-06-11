{pkgs,...}: {
  #
  # tmux
  #
  programs.tmux.enable = true;
  programs.tmux.keyMode = "vi";
  programs.tmux.prefix = "C-a";
  programs.tmux.newSession = true;
  programs.tmux.plugins = with pkgs; [
    tmuxPlugins.sensible
  ];
  programs.tmux.extraConfig = ''
    bind-key -T copy-mode-vi u send-keys -X  halfpage-up
    bind-key -T copy-mode-vi d send-keys -X  halfpage-down
    bind-key -T prefix b copy-mode
  '';
}
