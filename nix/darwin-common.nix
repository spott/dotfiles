{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config = import ./nixpkgs-config-darwin.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config-darwin.nix;

  nix.package = pkgs.nix;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-platforms = ["x86_64-darwin" "aarch64-darwin"];
  };

  #
  # Poetry
  #
  xdg.configFile."pypoetry/config.toml".source = ./pypoetry/config.toml;

  # 1password config
  xdg.configFile."1Password/ssh/agent.toml".source = ./1Password/ssh/agent.toml;

  #
  # SSH
  #
  programs.ssh.includes = [ "/Users/spott/.dstack/ssh/config" ];
  programs.ssh.extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"\nSetEnv TERM=\"xterm-color\"";

  #
  # Kitty
  #
  programs.kitty.enable = true;
  programs.kitty.theme = "Dracula";
  programs.kitty.settings = {
    #"include" = "./dracula.conf";
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
    "enable_audio_bell" = "no";
    "visual_bell_duration" = "0.1";

    "scrollback_lines" = "100000";
    "scrollback_pager" = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
    "scrollback_pager_history_size" = "100";

    "update_check_interval" = "0";

    "window_border_width" = "0.0pt";
    "inactive_text_alpha" = "0.9";
    "resize_draw_strategy" = "size";

    "tab_bar_edge" = "top";
    "tab_bar_style" = "slant";

    "macos_option_as_alt" = "yes";
    "macos_show_window_title_in" = "menubar";

    #"enabled_layouts" = "splits *";

    "map f4" = "launch --location=split";
    "map f5" = "launch --location=hsplit";
    "map f6" = "launch --location=vsplit";

    "map f7" = "layout_action rotate";

    # Move the active window in the indicated direction
    "map shift+up" = "move_window up";
    "map shift+left" = "move_window left";
    "map shift+right" = "move_window right";
    "map shift+down" = "move_window down";

    # Move the active window to the indicated screen edge
    "map ctrl+shift+up" = "layout_action move_to_screen_edge top";
    "map ctrl+shift+left" = "layout_action move_to_screen_edge left";
    "map ctrl+shift+right" = "layout_action move_to_screen_edge right";
    "map ctrl+shift+down" = "layout_action move_to_screen_edge bottom";

    # Switch focus to the neighboring window in the indicated direction
    "map ctrl+left" = "neighboring_window left";
    "map ctrl+right" = "neighboring_window right";
    "map ctrl+up" = "neighboring_window up";
    "map ctrl+down" = "neighboring_window down";

  };
}
