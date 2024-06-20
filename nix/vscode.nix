{
  config,
  pkgs,
  ...
}: {

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
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-azuretools.vscode-docker
    pkgs.vscode-marketplace.continue.continue
    pkgs.vscode-marketplace.ms-vscode.cpptools
    pkgs.vscode-marketplace.charliermarsh.ruff
    github.copilot
    github.copilot-chat
    pkgs.vscode-marketplace.rangav.vscode-thunder-client	
    pkgs.vscode-marketplace.mattflower.aider
    pkgs.vscode-marketplace.mkhl.direnv
    pkgs.vscode-marketplace.alexcvzz.vscode-sqlite

    pkgs.vscode-marketplace.doublebot.doublebot

    ###
    # Android stuff
    ###
    pkgs.vscode-marketplace.mathiasfrohlich.kotlin

  ];

  programs.vscode.userSettings = {
    "git.autofetch" = false;
    "workbench.colorTheme" = "Dracula";
    "vscode-neovim.neovimExecutablePaths.darwin" = "/Users/spott/.nix-profile/bin/nvim";
    "vscode-neovim.neovimInitVimPaths.darwin" = "/Users/spott/.config/nvim/init.lua";

    "editor.accessibilitySupport" = "off";
    "editor.fontFamily" = "Victor Mono";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 12.5;
    "editor.fontWeight" = "300";
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
    "terminal.external.osxExec" = "/Users/spott/.nix-profile/Applications/kitty.app";
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
    "python.analysis.extraPaths" = [
      "/Users/spott/.vscode/extensions/continue.continue-0.9.4-darwin-arm64"
    ];
    "python.analysis.inlayHints.callArgumentNames" = "all";
    "python.analysis.inlayHints.functionReturnTypes"= true;
    "python.analysis.inlayHints.pytestParameters"= true;
    "python.analysis.inlayHints.variableTypes"= true;
    "python.autoComplete.extraPaths" = [
      "/Users/spott/.vscode/extensions/continue.continue-0.9.4-darwin-arm64"
    ];
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
    "continue.enableTabAutocomplete" = false;
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
    
    "doublebot.chatModel" = "Claude 3 (Opus)";
    "github.copilot.editor.enableAutoCompletions" = true;
  };
}
