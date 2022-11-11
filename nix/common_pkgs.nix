{pkgs,...}:
with pkgs; [
# shell
  delta # diff pager
  difftastic # diff engine
  bottom # top replacement
  du-dust # du replacement
  fd # find replacement
  ripgrep # grep replacement
  duf # df replacement
  dogdns # dig replacement
  lsd # ls replacement... I'm using exa, so this might not be necessary
  sd # sed replacement
  tldr # examples for commands
  mosh # ssh replacement

# development
  #python310Packages.poetry
  (poetry.override {python = python310;})
  python39Full
]
