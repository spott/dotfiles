{
  ...
}: {


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

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

  use_conda() {
    local ACTIVATE="/opt/homebrew/Caskroom/miniconda/base/bin/activate"

    if [ -n "$1" ]; then
      # Explicit environment name from layout command.
      local env_name="$1"
      source $ACTIVATE $env_name
    elif (grep -q name: environment.yml); then
      # Detect environment name from `environment.yml` file in `.envrc` directory
      source $ACTIVATE `grep name: environment.yml | sed -e 's/name: //' | cut -d "'" -f 2 | cut -d '"' -f 2`
    else
      (>&2 echo No environment specified);
      exit 1;
    fi;
  }

  aws_sso() {
    local PROFILE=$1
    AWS_SSO=$(aws sts get-caller-identity --query "Account" --profile $PROFILE)
    if [ $\{#AWS_SSO\} -eq 14 ]; then
      echo "Valid AWS SSO Sessions found."
      export AWS_PROFILE=$PROFILE
    else
      echo "No valid AWS SSO Sessions found."
      aws sso login --profile=$PROFILE
      export AWS_PROFILE=$PROFILE
    fi
  }
  '';
  programs.direnv.enableZshIntegration = true;

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
  xdg.configFile."nvim/lua/lsp.lua".source = ./nvim/lua/lsp.lua;

  #
  # SSH
  #
  programs.ssh.enable = true;
  programs.ssh.controlMaster = "auto";
  programs.ssh.controlPersist = "30m";
  programs.ssh.controlPath = "~/.cache/ssh/master-%r@%n:%p";


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
  # aria2  (https://aria2.github.io, multi-protocol download utility
  # 
  programs.aria2.enable = true;

  #
  # gh (github commandline)
  #
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";

  #
  # poetry
  #
  # programs.poetry.enable = true;
  # programs.poetry.settings = {
  #   virtualenvs.in-project = true;
  #   virtualenvs.prefer-active-python = true;
  #   virtualenvs.options.always-copy = true;
  # };

  #
  # git
  #
  #xdg.configFile."git/config".source = ./git/config;
  programs.git.enable = true;
  programs.git.userName = "Andrew Spott";
  programs.git.userEmail = "andrew.spott@gmail.com";
  programs.git.delta.enable = true;
  programs.git.delta.options = {
    navigate = true;
    light = false;
  };
  programs.git.extraConfig = {
    init.defaultBranch = "main";
    push.autosetupRemote = true;
    merge.conflictstyle = "diff3";
    diff.colorMoved = "default";
  };

}
