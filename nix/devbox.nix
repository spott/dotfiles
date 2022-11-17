{ config, pkgs, lib, ... }:
let
  common = import ./common_vars.nix {inherit pkgs;};
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/home/spott";
	
 # inherit zsh;
  # Packages:
  home.packages = with pkgs; [
    _1password
  # iac (only needed on Normandy... but might as well install them everywhere
    terraform
    ansible
    pulumi-bin
    kubectl
    kubernetes-helm
    k9s
  ] ++ common.packages;

  programs.zsh.dirHashes = common.dirHashes // {
    code  = "$HOME/code";
    hl    = "$HOME/Homelab";
  };

  #programs.ssh.extraConfig = "IdentityAgent ~/.1password/agent.sock";
} 
