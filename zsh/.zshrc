source "/Users/spott/.config/zsh/.zshrc_personal"

typeset -U path cdpath fpath manpath



for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

HELPDIR="/nix/store/h61gsvc70l2vlfc1ap2bbi2c28bw0mw7-zsh-5.9/share/zsh/$ZSH_VERSION/help"









# Oh-My-Zsh/Prezto calls compinit during initialization,
# calling it twice causes slight start up slowdown
# as all $fpath entries will be traversed again.
autoload -U compinit && compinit









# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$ZDOTDIR/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY




# Aliases


# Global Aliases


# Named Directory Hashes




