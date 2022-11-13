{pkgs,...}:
{
packages = with pkgs; [
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
  yq # jq replacement for yaml files and xml files as well

  # fonts:
  victor-mono

  # nvim stuff
  tree-sitter

  # python development
  #python310Packages.poetry
  black
  prospector
  pyright
  (poetry.override {python = python310;})
  python39Full

  # nix developmentt
  alejandra
  rnix-lsp
];

dirHashes = {
    nix   = "$HOME/.dotfiles/nix";
    docs  = "$HOME/Documents";
};

}

