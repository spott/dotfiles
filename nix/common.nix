{config, pkgs, ...}:
{
  xdg.configFile."git/config".source = ./git/config;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #
  # bat (cat replacement)
  #
  programs.bat.enable = true;
  programs.bat.config = {
    theme = "Dracula";
  };


  #
  # bottom (btm command, top replacement)
  #
  programs.bottom.enable = true;
  # see https://github.com/ClementTsang/bottom/blob/master/sample_configs/default_config.toml for possiblities
  #programs.bottom.settings

  #
  # direnv
  #
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  #
  # exa (ls replacement)
  #
  programs.exa.enable = true;

  # 
  # tmux
  #
  programs.tmux.enable = true;
  programs.tmux.keyMode= "vi";
  programs.tmux.prefix = "C-a";

  #
  # neovim
  #
  programs.neovim.enable = true;
  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;
  xdg.configFile."nvim/lua/bootstrap.lua".source = ./nvim/lua/bootstrap.lua;

  # 
  # SSH
  #
  programs.ssh.enable = true;
  #programs.ssh.extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

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
  # fzf
  #
  programs.fzf.enable = true;

  #
  # aria2
  #
  programs.aria2.enable = true;
  
  #
  # gh (github commandline)
  # 
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
}
