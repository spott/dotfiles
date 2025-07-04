{pkgs, ...}: {
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
    env_file=''${1:-.oprc}
    [[ -f $env_file ]] || return 0
    direnv_load op run --env-file "$env_file" --no-masking -- direnv dump
  }


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

  layout_uv() {
    if [[ -d ".venv" ]]; then
        VIRTUAL_ENV="$(pwd)/.venv"
    fi

    if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
        log_status "No virtual environment exists. Executing \`uv venv\` to create one."
        uv venv
        VIRTUAL_ENV="$(pwd)/.venv"
    fi

    PATH_add "$VIRTUAL_ENV/bin"
    export UV_ACTIVE=1  # or VENV_ACTIVE=1
    export VIRTUAL_ENV
  }
  '';
  programs.direnv.enableZshIntegration = true;

}
