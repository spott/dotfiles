{pkgs,...}: {
  #
  # tmux
  #
  programs.tmux.enable = true;
  programs.tmux.keyMode = "vi";
  programs.tmux.prefix = "C-a";
  programs.tmux.newSession = true;
  programs.tmux.mouse = true;
  programs.tmux.aggressiveResize = true;
  programs.tmux.terminal = "tmux-256color";
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

    # set the window size to be the same as whatever your current terminal is
    # this might be too agressive, we will see.
    set-window-option -g aggressive-resize on

    # colors:
    set -as terminal-overrides ",*:Tc"
    set -as terminal-features ",*:RGB"

    # status bar settings:

    ##### left side: host | session (“tab”)
    # #H = host, #h = short host, #S = session name
    set -g status-left-length 40
    set -g status-left '#[bold]#h#[default] #[fg=colour245]|#[default] #S '

    ##### window list: show index:name; highlight current
    # #I = window index, #W = window name
    setw -g monitor-activity on
    setw -g automatic-rename on

    set -g window-status-format ' #I:#W '
    set -g window-status-current-format '#[bold,reverse] #I:#W #[default]'

    ##### right side
    # Pane index and (if available) pane title
    # #{pane_index} = 0,1,2... ; #{pane_title} often tracks the terminal title
    #set -g status-right-length 40
    set -g status-right 'pane #{pane_index}: #{pane_title}  %Y-%m-%d %H:%M'
    # if we want time:
    #set -g status-right '%Y-%m-%d %H:%M'
  ''; # set -g default-command "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${pkgs.zsh}/bin/zsh"
}
