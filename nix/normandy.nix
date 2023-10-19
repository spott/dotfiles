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
      terraform
      ansible
      pulumi-bin
      kubectl
      kubernetes-helm
      k9s
      runpodctl

      # remote
      wireguard-tools
    ]
    ++ common.packages;

  programs.zsh.dirHashes =
    common.dirHashes
    // {
      code = "$HOME/code";
      hl = "$HOME/Documents/Homelab";
    };

  programs.ssh.matchBlocks."*.sc.spott.us".identityFile = "~/.ssh/sc.spott.us.pub";
  programs.ssh.matchBlocks."*.sc.spott.us".identitiesOnly = true;
  programs.ssh.matchBlocks."*.sc.spott.us".forwardAgent = true;
  programs.ssh.matchBlocks."*.sc.spott.us".host = "*.sc.spott.us";

  programs.ssh.matchBlocks."10.42.1.*".identityFile = "~/.ssh/sc.spott.us.pub";
  programs.ssh.matchBlocks."10.42.1.*".identitiesOnly = true;
  programs.ssh.matchBlocks."10.42.1.*".forwardAgent = true;
  programs.ssh.matchBlocks."10.42.1.*".host = "10.42.1.*";

  programs.ssh.matchBlocks."104.171.202.10".identityFile = "~/.ssh/lambdalabs.pub";
  programs.ssh.matchBlocks."104.171.202.10".identitiesOnly = true;
  programs.ssh.matchBlocks."104.171.202.10".forwardAgent = true;
  programs.ssh.matchBlocks."104.171.202.10".host = "104.171.202.10";

  programs.ssh.matchBlocks."152.70.120.177".identityFile = "~/.ssh/lambdalabs.pub";
  programs.ssh.matchBlocks."152.70.120.177".identitiesOnly = true;
  programs.ssh.matchBlocks."152.70.120.177".forwardAgent = true;
  programs.ssh.matchBlocks."152.70.120.177".host = "152.70.120.177";

  programs.ssh.matchBlocks."ha.sc.spott.us".host = "ha.sc.spott.us";
  programs.ssh.matchBlocks."ha.sc.spott.us".user = "root";

  programs.ssh.matchBlocks."10.42.0.101".identityFile = "~/.ssh/moneta-root.pub";
  programs.ssh.matchBlocks."10.42.0.101".identitiesOnly = true;
  programs.ssh.matchBlocks."10.42.0.101".host = "10.42.0.101";
  programs.ssh.matchBlocks."10.42.0.101".user = "root";
}
