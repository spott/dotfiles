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


conda_env() {
	echo "nothing" > /dev/null;
}

pyenv_env() {
	# Use neovim instead of vim:
	alias vim=nvim

	#activate autoenv
	if [ -f "/usr/local/opt/autoenv/activate.sh" ]; then
		source /usr/local/opt/autoenv/activate.sh
	fi

	# settings for python virtualenvwrapper
	export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
	export WORKON_HOME=$HOME/.virtualenvs
	export PROJECT_HOME=$HOME/code
	if [ -f "/usr/local/bin/virtualenvwrapper.sh" ]; then
		source /usr/local/bin/virtualenvwrapper.sh
	fi

	# Only allow pip commands if within a virtual environment
	export PIP_REQUIRE_VIRTUALENV=true
	# Provide alias `gpip` to install python packages outside a virtualenv
	gpip3(){
		PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
	}


}

case `hostname` in 
	(Gauss) conda_env;;
	(Galactica.local) pyenv_env;;
	(*) echo "Unknown host";;
esac

# directory options:
setopt AUTO_CD
setopt AUTO_PUSHD
setopt EXTENDED_GLOB

# 10 second wait if you do something that will delete everything.  I wish I'd had this before...
setopt RM_STAR_WAIT

# hows about arrays be awesome?  (that is, frew${cool}frew has frew surrounding all the variables, not just first and last
setopt RC_EXPAND_PARAM

# Incremental search is elite!
bindkey -M vicmd "/" history-incremental-search-backward
bindkey -M vicmd "?" history-incremental-search-forward

# Search based on what you typed in already
bindkey -M vicmd "//" history-beginning-search-backward
bindkey -M vicmd "??" history-beginning-search-forward

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
