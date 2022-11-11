{ config, pkgs, lib, ... }:
let
  common = import ./common.nix {inherit config pkgs;};
in
lib.mkMerge[
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";
	
  # Packages:
  home.packages = common.packages;
} 
common.common]
