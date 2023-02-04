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

  #
  # SSH
  #
  programs.ssh.enable = true;
  programs.ssh.extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

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
    "disable_ligatures" = "never";
    "font_features VictorMono-Light" = "+ss06 +ss03 +ss01 +ss07";
    "font_features VictorMono-Medium" = "+ss06 +ss03 +ss01";
    "font_features VictorMono-MediumItalic" = "+ss06 +ss03 +ss01";
    "font_features VictorMono-Italic" = "+ss06 +ss03 +ss01";
    "enable_audio_bell" = "no";
    "visual_bell_duration" = "0.0";

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

    "shell_integration" = "disabled";
  };
}
