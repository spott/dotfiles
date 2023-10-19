{
  config,
  pkgs,
  ...
}: {
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
  programs.direnv.stdlib = ''
  layout_poetry() {
    PYPROJECT_TOML="''${PYPROJECT_TOML:-pyproject.toml}"
    if [[ ! -f "$PYPROJECT_TOML" ]]; then
        log_status "No pyproject.toml found. Executing \`poetry init\` to create a \`$PYPROJECT_TOML\` first."
        poetry init
    fi

    if [[ -d ".venv" ]]; then
        VIRTUAL_ENV="$(pwd)/.venv"
    else
        VIRTUAL_ENV=$(poetry env info --path 2>/dev/null ; true)
    fi

    if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
        log_status "No virtual environment exists. Executing \`poetry install\` to create one."
        poetry install
        VIRTUAL_ENV=$(poetry env info --path)
    fi

    PATH_add "$VIRTUAL_ENV/bin"
    export POETRY_ACTIVE=1
    export VIRTUAL_ENV
  }

  use_oprc() {
    # from https://github.com/venkytv/direnv-op/blob/main/oprc.sh
    [[ -f .oprc ]] || return 0
    direnv_load op run --env-file .oprc --no-masking -- direnv dump
  }

  watch_file .oprc
  '';
  programs.direnv.enableZshIntegration = true;

  #
  # exa (ls replacement)
  # replaced by eza...
  #
  #programs.exa.enable = true;

  #
  # tmux
  #
  programs.tmux.enable = true;
  programs.tmux.keyMode = "vi";
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
  programs.ssh.controlMaster = "auto";
  programs.ssh.controlPersist = "30m";
  programs.ssh.controlPath = "~/.cache/ssh/master-%r@%n:%p";

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
    ms-python.python #<- currenv version (2022.19.xxxx) uses a version of debugpython that doesn't work.
    ms-python.vscode-pylance
    redhat.vscode-yaml
    ms-toolsai.jupyter
    ms-toolsai.jupyter-renderers
    ms-toolsai.jupyter-keymap
    ms-vscode-remote.remote-ssh
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-azuretools.vscode-docker
    pkgs.vscode-marketplace.continue.continue
    #continue.continue
  ];# ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
#      {
#        name = "continue";
#        publisher = "Continue";
#        version = "0.47.2";
#        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
#      };

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
    "python.analysis.typeCheckingMode" = "basic";
    "python.formatting.provider" = "black";
    "python.formatting.blackPath" = "~/.nix-profile/bin/black";
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
    "extensions.experimental.affinity" = {
      "asvetliakov.vscode-neovim" = 1;
    };
  };

  #
  # fzf
  #
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.fzf.colors = {
    fg="-1";
    bg="-1";
    hl="#5fff87";
    "fg+"="-1";
    "bg+"="-1";
    "hl+"="#ffaf5f";
    info="#af87ff";
    prompt="#5fff87";
    pointer="#ff87d7";
    marker="#ff87d7";
    spinner="#ff87d7";
  };

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
