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
    bind-key -T copy-mode-vi v send -X begin-selection
    bind-key -T copy-mode-vi y send -X copy-selection-and-cancel
    bind-key -T prefix b copy-mode
    set -gu default-command
    set -g default-shell ${pkgs.zsh}/bin/zsh
    set -g mouse on

    # colors:
    set -g default-terminal "tmux-256color"
    set -as terminal-overrides ",*:Tc"
    set -as terminal-features ",*:RGB"

  ''; # set -g default-command "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${pkgs.zsh}/bin/zsh"
}
