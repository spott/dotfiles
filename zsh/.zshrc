#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
[[ "$TERM" == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# Customize to your needs...


ubuntu_env() {
	echo "Welcome to ${hostname}"
}

zeus_env() {
	echo "Welcome to Zeus"
	#activate autoenv
	#if [ -f "/usr/local/opt/autoenv/activate.sh" ]; then
		#source /usr/local/opt/autoenv/activate.sh
	#fi

	# settings for python virtualenvwrapper
	#export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
	#export WORKON_HOME=$HOME/.virtualenvs
	export PROJECT_HOME=$HOME/code
	export PATH=/usr/local/cuda-9.0/bin${PATH:+:${PATH}}
	export export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

	#if [ -f "/usr/local/bin/virtualenvwrapper.sh" ]; then
		#source /usr/local/bin/virtualenvwrapper.sh
	#fi

	# Only allow pip commands if within a virtual environment
	#export PIP_REQUIRE_VIRTUALENV=true

	# Provide alias `gpip` to install python packages outside a virtualenv
	#gpip3(){
		#PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
	#}
}

darwin_env() {
	echo "Welcome to ${hostname}"
	# Use neovim instead of vim:
	alias vim=nvim

	#activate autoenv
	if [ -f "/usr/local/opt/autoenv/activate.sh" ]; then
		source /usr/local/opt/autoenv/activate.sh
	fi

	# settings for python virtualenvwrapper
	#export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
	#export WORKON_HOME=$HOME/.virtualenvs
	export PROJECT_HOME=$HOME/code
	#if [ -f "/usr/local/bin/virtualenvwrapper.sh" ]; then
		#source /usr/local/bin/virtualenvwrapper.sh
	#fi
    export PATH=/Users/spott/.local/bin:/Users/spott/.cargo/bin/:$PATH
	# Only allow pip commands if within a virtual environment
	#export PIP_REQUIRE_VIRTUALENV=true
	# Provide alias `gpip` to install python packages outside a virtualenv
	gpip3(){
		PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
	}

	if [ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then
		source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
	fi
	if [ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]; then
		source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
	fi
}

#HNAME=(${(s/./)`hostname`})
HNAME=`hostname`

case $HNAME:l in 
	(gauss) ubuntu_env;;
	(Gauss) ubuntu_env;;
	(zeus) zeus_env;;
	(galactica*|pan*) darwin_env;;
	(*) echo "Unknown host";;
esac

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

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

#[[ $- == *i* && $SSH_TTY && -z $TMUX && ! -r ~/.notmux ]] && tmux -CC attach-session -d && exit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
