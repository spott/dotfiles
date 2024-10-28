{
  pkgs,
  ...
}: {
  # nixpkgs.config = import ./nixpkgs-config-darwin.nix;
  # xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config-darwin.nix;

  # nix.package = pkgs.nix;
  # nix.settings = {
  #   experimental-features = ["nix-command" "flakes"];
  #   extra-platforms = ["x86_64-darwin" "aarch64-darwin"];
  # };

  # #
  # # Poetry
  # #
  # xdg.configFile."pypoetry/config.toml".source = ./pypoetry/config.toml;

  # 1password config
  xdg.configFile."1Password/ssh/agent.toml".source = ./1Password/ssh/agent.toml;

  # aerospace config
  xdg.configFile."aerospace/aerospace.toml".source = ./aerospace/aerospace.toml;

  #
  # SSH
  #
  programs.ssh.includes = [ "/Users/spott/.dstack/ssh/config" ];
  programs.ssh.extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"\nSetEnv TERM=\"xterm-color\"";

  #
  # Kitty
  #
  programs.kitty.enable = true;
  programs.kitty.package = pkgs.stable.kitty;
  programs.kitty.themeFile = "Dracula";
  programs.kitty.settings = {
    # fonts:
    "font_family" = "Victor Mono Light";
    "bold_font" = "Victor Mono Medium";
    "italic_font" = "Victor Mono Light Italic";
    "bold_italic_font" = "Victor Mono Medium Italic";
    "font_size" = "12.5";
    "disable_ligatures" = "cursor";
    "font_features VictorMono-Light" = "+ss06 +ss03 +ss01 +ss07";
    "font_features VictorMono-Medium" = "+ss06 +ss03 +ss01";
    "font_features VictorMono-MediumItalic" = "+ss06 +ss03 +ss01";
    "font_features VictorMono-Italic" = "+ss06 +ss03 +ss01";

    # bells
    "enable_audio_bell" = "no";
    "visual_bell_duration" = "0.1";

    # decorations
    "macos_titlebar_color" = "background";
    "window_border_width" = "0.0pt";
    "inactive_text_alpha" = "0.9";
    "resize_draw_strategy" = "size";

    # scrollback
    "scrollback_lines" = "100000";
    "scrollback_pager" = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
    "scrollback_pager_history_size" = "100";

    "update_check_interval" = "0";
    
    # tab styles
    "tab_bar_edge" = "top";
    "tab_bar_style" = "slant";

    # macos options
    "macos_option_as_alt" = "yes";
    "macos_show_window_title_in" = "menubar";
    "macos_quit_when_last_window_closed" = "yes";

    #remote control
    "allow_remote_control" = "yes";
    "listen_on" = "unix:/tmp/mykitty";

    "enabled_layouts" = "splits,tall,fat,grid,stack";

    #
    # Keyboard shortcuts:
    #
    "clear_all_shortcuts" = "yes"; # playing with fire...

    # clipboard
    "map cmd+c" = "copy_to_clipboard";
    "map cmd+v" = "paste_from_clipboard";

    # scrolling
    # has a prefix "ctrl+s"
    "map ctrl+s>p" = "scroll_to_prompt -1"; # scroll to the last prompt
    "map ctrl+s>n" = "scroll_to_prompt 1"; # scroll to the next prompt
    "map ctrl+s>h" = "show_scrollback"; # browse entire scrollback buffer in pager
    "map ctrl+s>g" = "show_last_command_output"; # browse last command output in pager

    # tabs:
    "map cmd+shift+]" = "next_tab";
    "map cmd+shift+[" = "prev_tab";

    # kitty prefix: cmd+k
    "map cmd+k>f" = "kitten hints --type path --program -"; # highlights paths in the terminal with numbers to select them.  type number to insert that path into terminal
    "map cmd+k>h" = "kitten hints --type hash --program -"; # same as above, except for hashes
    "map cmd+k>c" = "kitty_shell window"; # enter kitty shell to control kitty
    "map cmd+k>u" = "kitten unicode_input"; # enter kitty shell to control kitty
    "map cmd+k>l" = "load_config_file"; # reload the kitty conf
    "map cmd+k>r" = "clear_terminal reset active"; # reset the active terminal window

    # move around windows, same(ish) mapping as in vim.
    # if in vim, then pass these keys to vim
    # moving
    "map ctrl+w>j" = "kitten pass_keys.py bottom ctrl+w>j";
    "map ctrl+w>k" = "kitten pass_keys.py top    ctrl+w>k";
    "map ctrl+w>h" = "kitten pass_keys.py left   ctrl+w>h";
    "map ctrl+w>l" = "kitten pass_keys.py right  ctrl+w>l";
    
    # splitting
    "map ctrl+w>s" = "kitten pass_keys.py launch|--location=hsplit|--match=id:{windowid}|--cwd=current ctrl+w>s";
    "map ctrl+w>v" = "kitten pass_keys.py launch|--location=vsplit|--match=id:{windowid}|--cwd=current ctrl+w>v";
    "map ctrl+w>c" = "kitten pass_keys.py close-window|--match=id:{windowid} ctrl+w>c"; # not sure why this doesn't work
    
    # rotating windows
    "map ctrl+w>r" = "kitten pass_keys.py action|--match=id:{windowid}|layout_action|rotate ctrl+w>r";

    # moving windows
    "map ctrl+w>x" = "kitten pass_keys.py action|--match=id:{windowid}|move_window_forward ctrl+w>x";
    "map ctrl+w>shift+x" = "kitten pass_keys.py action|--match=id:{windowid}|move_window_backward ctrl+w>shift+x";
    "map ctrl+w>shift+k" = "kitten pass_keys.py action|--match=id:{windowid}|move_window_to_top ctrl+w>shift+k";

    # moving windows to new tab
    "map ctrl+w>shift+t" = "kitten pass_keys.py detach_window|--target-tab=new|--match=id:{windowid} ctrl+w>shift+t";
    
    # resizing windows
    "map ctrl+w>=" = "kitten pass_keys.py resize_window|--match=id:{windowid}|--axis=reset ctrl+w>=";
    "map ctrl+w>-" = "kitten pass_keys.py resize_window|--match=id:{windowid}|--axis=vertical|--increment=-2 ctrl+w>-";
    "map ctrl+w>shift+=" = "kitten pass_keys.py resize_window|--match=id:{windowid}|--axis=vertical|--increment=+2 ctrl+w>shift+=";
    "map ctrl+w>shift+." = "kitten pass_keys.py resize_window|--match=id:{windowid}|--axis=horizontal|--increment=+2 ctrl+w>shift+.";
    "map ctrl+w>shift+," = "kitten pass_keys.py resize_window|--match=id:{windowid}|--axis=horizontal|--increment=-2 ctrl+w>shift+,";

    # OS Window:
    "map cmd+n" = "new_os_window";

    # change layout:
    "map cmd+w>t" = "goto_layout tall";
    "map cmd+w>f" = "goto_layout fat";
    "map cmd+w>s" = "goto_layout split";
    "map cmd+w>]" = "next_layout";
    "map cmd+w>[" = "next_layout -1";
    "map cmd+w>p" = "last_used_layout";
    "map cmd+w>z" = "toggle_layout_stack";

    # resizing
    "map cmd+w>r" = "start_resizing_window";
    "map cmd+r" = "start_resizing_window";

    "map cmd+w>g" = "focus_visible_window"; # show a visual overlay, after release, you can press a number to go to that window.
    
    # new windows
    "map cmd+w>n" = "new_window";
    "map cmd+w>shift+n" = "launch --cwd=current";

    # window focus
    "map cmd+w>1" = "first_window";
    "map cmd+w>2" = "second_window";
    "map cmd+w>3" = "third_window";
    "map cmd+w>4" = "fourth_window";
    "map cmd+w>5" = "fifth_window";
    "map cmd+w>6" = "sixth_window";
    "map cmd+w>7" = "seventh_window";
    "map cmd+w>8" = "eigth_window";
    "map cmd+w>9" = "ninth_window";

    # moving windows
    "map cmd+w>l" = "move_window right";
    "map cmd+w>h" = "move_window left";
    "map cmd+w>k" = "move_window up";
    "map cmd+w>j" = "move_window down";
    "map cmd+w>w" = "swap_with_window"; # same as above, but swaps current window with the chosen window.

    # detaching and moving windows and tabs
    "map ctrl+t>t" = "launch --type=tab";
    "map ctrl+t>d" = "detach_window ask";
    "map ctrl+t>n" = "detach_tab";
    "map ctrl+t>w" = "detach_tab ask";
  };

  # programs.rio.enable = true;
  # programs.rio.settings = {
  #   option-as-alt = "left";
  #   theme = "dracula";
  #   window.decorations = "Buttonless";
  #   navigation.mode = "CollapsedTab";
  #   renderer.performance = "Low";
  #   renderer.disable-unfocused-render = true;
  #   fonts.size = 14;
  #   fonts.regular.family = "Victor Mono";
  #   fonts.regular.style = "Light";
  #   fonts.bold.family = "Victor Mono";
  #   fonts.bold.style = "Medium";
  #   fonts.italic.family = "Victor Mono";
  #   fonts.italic.style = "Light Italic";
  #   fonts.bold-italic.family = "Victor Mono";
  #   fonts.bold-italic.style = "Medium Italic";
  #   keyboard.use-kitty-keyboard-protocol = true;
  # };
  # xdg.configFile."rio/themes/dracula.toml".source = ./rio/themes/dracula.toml;

  programs.wezterm.enable = true;
}
