#!/usr/bin/env zsh
emulate -L zsh
setopt err_exit no_unset pipe_fail

if (( $# != 2 )); then
  print -u2 -- "usage: ${0:t} LABEL HOME_MANAGER_GENERATION"
  exit 2
fi

label=$1
generation=$2
config_dir=$generation/home-files/.config/zsh
runtime_zsh=$generation/home-path/bin/zsh
runtime_path=$generation/home-path/bin:$PATH
tmp=$(mktemp -d)
pty_name=spott-zsh-smoke-$$

cleanup() {
  zpty -d $pty_name 2>/dev/null || true
  find $tmp -type d -exec chmod u+w {} + 2>/dev/null || true
  rm -rf $tmp
}
trap cleanup EXIT INT TERM

mkdir -p $tmp/.config
cp -R $config_dir $tmp/.config/zsh
chmod u+w $tmp/.config/zsh
rm -f $tmp/.config/zsh/.zshenv $tmp/.config/zsh/.zshrc
print -r -- 'export ZDOTDIR="$HOME/.config/zsh"' > $tmp/.config/zsh/.zshenv
print -r -- 'source "$ZDOTDIR/.zshrc_personal"' > $tmp/.config/zsh/.zshrc

zmodload zsh/zpty
checks_file=$tmp/checks.zsh
cat > $checks_file <<'EOF'
for fn in mkcd mkpw prompt-pwd duration-info-precmd duration-info-preexec coalesce git-action git-info; do
  (( ${+functions[$fn]} )) || { print -u2 -- "missing function: $fn"; exit 11; }
done
for widget in fzf-history-widget history-substring-search-up history-substring-search-down; do
  zle -l "$widget" >/dev/null || { print -u2 -- "missing widget: $widget"; exit 12; }
done
[[ ${fpath[1]} == "$ZDOTDIR/plugins/utility/functions" ]] || {
  print -u2 -- "wrong fpath head: ${fpath[1]}"
  exit 13
}
(( ${+functions[_zsh_highlight_highlighter_main_paint]} )) || exit 14
(( ${+functions[_zsh_highlight_highlighter_brackets_paint]} )) || exit 15
(( ${+functions[_zsh_autosuggest_start]} )) || exit 16
(( ${+functions[compdef]} )) || exit 17
[[ $ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR == "$ZDOTDIR/plugin-support/zsh-syntax-highlighting/highlighters" ]] || exit 18
[[ -n ${FZF_ALT_C_OPTS-} ]] || exit 19
(( ! ${+_spott_zsh_plugin_root} )) || exit 20
print -r -- __DECLARATIVE_ZSH_PTY_OK__
EOF

zpty "$pty_name" env \
  "HOME=$tmp" \
  "ZDOTDIR=$tmp/.config/zsh" \
  "PATH=$runtime_path" \
  "$runtime_zsh" -i "$checks_file"

output=
if ! zpty -r $pty_name output '*__DECLARATIVE_ZSH_PTY_OK__*'; then
  print -u2 -- "error: $label failed the PTY-backed interactive Zsh smoke test"
  print -u2 -r -- $output
  exit 1
fi

if [[ $output != *__DECLARATIVE_ZSH_PTY_OK__* ]]; then
  print -u2 -- "error: $label exited without the PTY smoke-test marker"
  print -u2 -r -- $output
  exit 1
fi

print -- "PTY-backed interactive startup passed for $label."
