{
  config,
  pkgs,
  ...
}: {

  programs.vscode.enable = true;
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    # nix/direnv
    arrterian.nix-env-selector
    jnoortheen.nix-ide
    pkgs.vscode-marketplace.mkhl.direnv
    kamadorueda.alejandra
    
    # editing env
    asvetliakov.vscode-neovim
    eamodio.gitlens
    dracula-theme.theme-dracula

    # remote/docker
    ms-vscode-remote.remote-ssh
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-azuretools.vscode-docker
    
    # Python
    pkgs.vscode-marketplace.charliermarsh.ruff
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-toolsai.jupyter-renderers
    ms-toolsai.jupyter-keymap

    # rest
    pkgs.vscode-marketplace.rangav.vscode-thunder-client

    # other languages
    #pkgs.vscode-marketplace.ms-vscode.cpptools
    pkgs.vscode-marketplace.alexcvzz.vscode-sqlite
    redhat.vscode-yaml

    # AI stuff
    #github.copilot
    #github.copilot-chat
    pkgs.vscode-marketplace.continue.continue
    #pkgs.vscode-marketplace.doublebot.doublebot
    pkgs.vscode-marketplace.mattflower.aider

    # Android stuff
    pkgs.vscode-marketplace.mathiasfrohlich.kotlin
    pkgs.vscode-marketplace.nefrob.vscode-just-syntax

  ];

  programs.vscode.profiles.default.userSettings = {
    "git.autofetch" = false;
    "workbench.colorTheme" = "Dracula";
    "vscode-neovim.neovimExecutablePaths.darwin" = "/etc/profiles/per-user/spott/bin/nvim";
    "vscode-neovim.neovimInitVimPaths.darwin" = "/Users/spott/.config/nvim/init.lua";

    "editor.accessibilitySupport" = "off";
    "editor.fontFamily" = "Victor Mono";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 13;
    "editor.fontWeight" = "400";
    "editor.renderWhitespace" = "trailing";
    "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
    "editor.formatOnPaste" = true;
    "editor.formatOnSave" = true;
    #"editor.minimap.autohide" = true;
    "workbench.preferredDarkColorTheme" = "Dracula";
    "workbench.editor.highlightModifiedTabs" = true;
    "workbench.settings.useSplitJSON" = true;
    "window.openFoldersInNewWindow" = "on";
    "explorer.fileNesting.expand" = false;
    "terminal.explorerKind" = "external";
    "terminal.external.osxExec" = "/Users/spott/Applications/Home Manager Apps/kitty.app";
    "terminal.integrated.defaultProfile.osx" = "zsh";

    "problems.showCurrentInStatus" = true;
    "[python]" = {
      "editor.defaultFormatter" = "charliermarsh.ruff";
      "editor.formatOnSave" = true;
    };
    "python.analysis.diagnosticMode" = "workspace";
    "python.analysis.autoImportCompletions" = true;
    "python.analysis.importFormat" = "relative";
    "python.analysis.indexing" = true;
    "python.analysis.typeCheckingMode" = "basic";
    # "python.analysis.extraPaths" = [
    #   "/Users/spott/.vscode/extensions/continue.continue-0.9.4-darwin-arm64"
    # ];
    "python.analysis.inlayHints.callArgumentNames" = "all";
    "python.analysis.inlayHints.functionReturnTypes"= true;
    "python.analysis.inlayHints.pytestParameters"= true;
    "python.analysis.inlayHints.variableTypes"= true;
    # "python.autoComplete.extraPaths" = [
    #   "/Users/spott/.vscode/extensions/continue.continue-0.9.4-darwin-arm64"
    # ];
    "ruff.showNotifications" = "always";
    "ruff.trace.server"= "messages";
    "python.terminal.activateEnvInCurrentTerminal" = true;
    "python.testing.pytestEnabled" = true;
    "python.analysis.autoFormatStrings" = true;
    "github.gitProtocol" = "ssh";
    "nix.enableLanguageServer" = true;
    "[nix]" = {
      "editor.defaultFormatter"= "kamadorueda.alejandra";
      "editor.formatOnPaste"= true;
      "editor.formatOnSave"= true;
    };
    "extensions.experimental.affinity" = {
      "asvetliakov.vscode-neovim" = 1;
    };
    "explorer.confirmDragAndDrop" = false;
    "continue.enableTabAutocomplete" = true;
    "editor.minimap.enabled" = false;

    #########
    ## Jupyter Notebook stuff:
    #########
    "jupyter.themeMatplotlibPlots" = true;
    "jupyter.askForKernelRestart" = false;
    "jupyter.allowUnauthorizedRemoteConnection" = true;
    "jupyter.interactiveWindow.textEditor.executeSelection" = true;
    # reduce whitespace for notebooks in vscode
    # from https://github.com/microsoft/vscode/issues/175295
    "editor.lineHeight"= 17;
    "notebook.insertToolbarLocation" = "notebookToolbar";
    "breadcrumbs.enabled"= false;
    "notebook.showCellStatusBar" = "hidden";
    "notebook.cellToolbarLocation" = {
        "jupyter-notebook" = "hidden";
    };
    "notebook.globalToolbar" = false;
    "notebook.output.scrolling" = true;
    "notebook.consolidatedRunButton" = true;
  };
}
