{zshSources}: [
  {
    name = "environment";
    src = zshSources.environment;
    initFiles = ["init.zsh"];
  }
  {
    name = "input";
    src = zshSources.input;
    initFiles = ["init.zsh"];
  }
  {
    name = "termtitle";
    src = zshSources.termtitle;
    initFiles = ["init.zsh"];
  }
  {
    name = "utility";
    src = zshSources.utility;
    fpath = ["functions"];
    autoload = ["mkcd" "mkpw"];
    initFiles = ["init.zsh"];
  }
  {
    name = "eza";
    src = zshSources.zimfw-eza;
    initFiles = ["init.zsh"];
  }
  {
    name = "magic-enter";
    src = zshSources.magic-enter;
    initFiles = ["init.zsh"];
  }
  {
    name = "prompt-pwd";
    src = zshSources.prompt-pwd;
    fpath = ["functions"];
    autoload = ["prompt-pwd"];
  }
  {
    name = "per-directory-history";
    src = zshSources.per-directory-history;
    initFiles = ["per-directory-history.zsh"];
  }
  {
    name = "zsh-vi-mode";
    src = zshSources.zsh-vi-mode;
    initFiles = ["zsh-vi-mode.zsh"];
  }
  {
    name = "fzf";
    initExtra = ''
      source "$ZDOTDIR/fzf.zsh"
    '';
  }
  {
    name = "walltime";
    src = zshSources.walltime;
    initFiles = ["walltime.plugin.zsh"];
  }
  {
    name = "duration-info";
    src = zshSources.duration-info;
    fpath = ["functions"];
    autoload = ["duration-info-precmd" "duration-info-preexec"];
    initFiles = ["init.zsh"];
  }
  {
    name = "git-info";
    src = zshSources.git-info;
    fpath = ["functions"];
    autoload = ["coalesce" "git-action" "git-info"];
  }
  {
    name = "minimal";
    src = zshSources.minimal;
    initFiles = ["minimal.zsh-theme"];
  }
  {
    name = "zsh-completions";
    src = zshSources.zsh-completions;
    fpath = ["src"];
  }
  {
    name = "completion";
    src = zshSources.completion;
    fpath = ["functions"];
    initFiles = ["init.zsh"];
  }
  {
    name = "zsh-syntax-highlighting";
    src = zshSources.zsh-syntax-highlighting;
    initBefore = ''
      ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$ZDOTDIR/plugin-support/zsh-syntax-highlighting/highlighters"
    '';
    initFiles = ["zsh-syntax-highlighting.zsh"];
    preloadFiles = [
      "highlighters/brackets/brackets-highlighter.zsh"
      "highlighters/cursor/cursor-highlighter.zsh"
      "highlighters/line/line-highlighter.zsh"
      "highlighters/main/main-highlighter.zsh"
      "highlighters/pattern/pattern-highlighter.zsh"
      "highlighters/regexp/regexp-highlighter.zsh"
      "highlighters/root/root-highlighter.zsh"
    ];
  }
  {
    name = "zsh-history-substring-search";
    src = zshSources.zsh-history-substring-search;
    initFiles = ["zsh-history-substring-search.zsh"];
  }
  {
    name = "zsh-autosuggestions";
    src = zshSources.zsh-autosuggestions;
    initFiles = ["zsh-autosuggestions.zsh"];
  }
]
