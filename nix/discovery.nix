{
  config,
  pkgs,
  ...
}: let
  common = import ./packages.nix {inherit pkgs;};
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "andrew.spott";
  home.homeDirectory = "/Users/andrew.spott";

  # Packages:
  home.packages = common.packages ++ [
    (pkgs.azure-cli.withExtensions [ pkgs.azure-cli.extensions.fzf pkgs.azure-cli.extensions.storagesync pkgs.azure-cli.extensions.ai-examples pkgs.azure-cli.extensions.cli-translator ])
    pkgs.azure-storage-azcopy
  ];
  programs.zsh.dirHashes =
    common.dirHashes
    // {
      proj = "$HOME/projects";
    };
}
