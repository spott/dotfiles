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
    extra-platforms = ["x86_64_darwin" "aarch64_darwin"];
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
  # vscode:
  #
  programs.vscode.enable = true;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    asvetliakov.vscode-neovim
    arrterian.nix-env-selector
    jnoortheen.nix-ide
    kamadorueda.alejandra
    dracula-theme.theme-dracula
    eamodio.gitlens
    ms-python.python
    ms-python.vscode-pylance
    redhat.vscode-yaml
    ms-toolsai.jupyter
    ms-toolsai.jupyter-renderers
    ms-toolsai.jupyter-keymap
    ms-vscode-remote.remote-ssh
  ];

  programs.vscode.userSettings = {
    "workbench.colorTheme" = "Dracula";
    "vscode-neovim.neovimExecutablePaths.darwin" = "/Users/spott/.nix-profile/bin/nvim";
    "vscode-neovim.neovimInitVimPaths.darwin" = " /Users/spott/.config/nvim/init.lua";
    "jupyter.sendSelectionToInteractiveWindow" = true;
    "jupyter.themeMatplotlibPlots" = true;
    "jupyter.askForKernelRestart" = false;
    "jupyter.allowUnauthorizedRemoteConnection" = true;
    "git.autofetch" = false;
    "editor.accessibilitySupport" = "off";
    "editor.fontFamily" = "Victor Mono";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 12.5;
    "editor.fontWeight" = "300";
    "editor.renderWhitespace" = "trailing";
    "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
    "editor.formatOnPaste" = true;
    "editor.formatOnSave" = true;
    "editor.minimap.autohide" = true;
    "workbench.preferredDarkColorTheme" = "Dracula";
    "workbench.editor.highlightModifiedTabs" = true;
    "workbench.settings.useSplitJSON" = true;
    "window.openFoldersInNewWindow" = "on";
    "explorer.fileNesting.expand" = false;
    "terminal.explorerKind" = "external";
    "terminal.external.osxExec" = "/Users/spott/.nix-profile/Applications/kitty.app";
    "terminal.integrated.defaultProfile.osx" = "zsh";
    "problems.showCurrentInStatus" = true;
    "[python]" = {
      "editor.formatOnType" = true;
    };
    "python.analysis.diagnosticMode" = "workspace";
    "python.analysis.autoImportCompletions" = true;
    "python.analysis.importFormat" = "relative";
    "python.analysis.indexing" = true;
    "python.analysis.typeCheckingMode" = "strict";
    "python.formatting.provider" = "black";
    "python.linting.mypyEnabled" = true;
    "python.linting.mypyPath" = "~/.nix-profile/bin/mypy";
    "python.linting.prospectorEnabled" = true;
    "python.linting.prospectorPath" = "~/.nix-profile/bin/prospector";
    "python.terminal.activateEnvInCurrentTerminal" = true;
    "python.testing.pytestEnabled" = true;
    "github.gitProtocol" = "ssh";
    "nix.enableLanguageServer" = true;
    "source.fixAll.convertImportFormat" = true;
    "source.fixAll.unusedImports" = true;
  };

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
