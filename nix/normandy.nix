{
  config,
  pkgs,
  lib,
  ...
}: let
  common = import ./packages.nix {inherit pkgs;};
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";

  # inherit zsh;
  # Packages:
  home.packages = with pkgs;
    [
      # iac (only needed on Normandy
      opentofu
      stable.ansible
      #pulumi-bin
      kubectl
      kubernetes-helm
      k9s
      runpodctl
      findutils

      lima
      colima
      docker-client
      docker-compose
      docker-buildx

      # docker
      dive

      # remote
      #wireguard-tools
      skimpdf
    ]
    ++ common.packages;

  programs.zsh.dirHashes =
    common.dirHashes
    // {
      code = "$HOME/code";
      hl = "$HOME/Documents/Homelab";
    };

  programs.ssh.matchBlocks."10.42.1.2".host = "moneta 10.42.1.2";
  programs.ssh.matchBlocks."10.42.1.2".hostname = "10.42.1.2";
  programs.ssh.matchBlocks."10.42.1.2".identityFile = ["~/.ssh/spott.moneta.pub" "~/.ssh/ansible.moneta.pub" "~/.ssh/root.moneta.pub"];
  #programs.ssh.matchBlocks."10.42.1.2".extraOptions = {"IdentityFile" = "~/.ssh/ansible.moneta.pub";};
  programs.ssh.matchBlocks."10.42.1.2".identitiesOnly = true;

  programs.ssh.matchBlocks."10.42.0.107" = {
    host = "nix-build 10.42.0.107";
    hostname = "10.42.0.107";
    identityFile = [ "~/.ssh/spott.sc.spott.us.pub" ];
    identitiesOnly = true;
  };
}
