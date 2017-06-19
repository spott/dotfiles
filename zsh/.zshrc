#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# Use neovim instead of vim:
alias vim=nvim

#activate autoenv
source /usr/local/opt/autoenv/activate.sh

# settings for python virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/code
source /usr/local/bin/virtualenvwrapper.sh

# Only allow pip commands if within a virtual environment
export PIP_REQUIRE_VIRTUALENV=true
# Provide alias `gpip` to install python packages outside a virtualenv
gpip3(){
   PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}
