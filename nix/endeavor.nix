{
  config,
  pkgs,
  ...
}: let
  common = import ./packages.nix {inherit pkgs;};
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";

  # Packages:
  home.packages = common.packages;
  programs.zsh.dirHashes =
    common.dirHashes
    // {
      proj = "$HOME/projects";
      docs = "$HOME/iCloudDocuments";
    };
}
