{ config, pkgs, ... }:
let
  common_pkgs = import ./common_pkgs.nix {inherit pkgs;};
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";
	
  # Packages:
  home.packages = common_pkgs;
} 
