{...}: {
  programs.rio.enable = true;
  programs.rio.settings = {
    option-as-alt = "left";
    theme = "dracula";
    window.decorations = "Buttonless";
    navigation.mode = "CollapsedTab";
    renderer.performance = "Low";
    renderer.disable-unfocused-render = true;
    fonts.size = 14;
    fonts.regular.family = "Victor Mono";
    fonts.regular.style = "Light";
    fonts.bold.family = "Victor Mono";
    fonts.bold.style = "Medium";
    fonts.italic.family = "Victor Mono";
    fonts.italic.style = "Light Italic";
    fonts.bold-italic.family = "Victor Mono";
    fonts.bold-italic.style = "Medium Italic";
    keyboard.use-kitty-keyboard-protocol = true;
  };
  xdg.configFile."rio/themes/dracula.toml".source = ./rio/themes/dracula.toml;
}
