{config, pkgs, ...}:
{
  nixpkgs.config = import ./nixpkgs-config-darwin.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config-darwin.nix;

  nix.package = pkgs.nix;
  nix.settings = { experimental-features = [ "nix-command" "flakes" ]; 
                   extra-platforms = [ "x86_64_darwin" "aarch64_darwin" ]; };

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
    "editor.fontLigatures"= true;
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
    "python.linting.mypyPath"= "~/.nix-profile/bin/mypy";
    "python.linting.prospectorEnabled" = true;
    "python.linting.prospectorPath"= "~/.nix-profile/bin/prospector";
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
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."kitty/dracula.conf".source = ./kitty/dracula.conf;
  xdg.configFile."kitty/diff.conf".source = ./kitty/diff.conf;
}
