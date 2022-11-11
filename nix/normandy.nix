{ config, pkgs, lib, ... }:
let
  common_pkgs = import ./common_pkgs.nix {inherit pkgs;};
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";
	
 # inherit zsh;
  # Packages:
  home.packages = with pkgs; [
  # iac (only needed on Normandy... but might as well install them everywhere
    terraform
    ansible
    pulumi-bin
    kubectl
    kubernetes-helm
  ] ++ common_pkgs;
} 
