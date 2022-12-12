{
  config,
  pkgs,
  lib,
  ...
}: let
  common = import ./common_vars.nix {inherit pkgs;};
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

      # remote
      wireguard-tools
    ]
    ++ common.packages;

  programs.zsh.dirHashes =
    common.dirHashes
    // {
      code = "$HOME/Documents/code";
      hl = "$HOME/Documents/Homelab";
    };

  programs.ssh.matchBlocks."*.sc.spott.us".identityFile = "~/.ssh/sc.spott.us.pub";
  programs.ssh.matchBlocks."*.sc.spott.us".identitiesOnly = true;
  programs.ssh.matchBlocks."*.sc.spott.us".forwardAgent = true;
  programs.ssh.matchBlocks."*.sc.spott.us".host = "*.sc.spott.us";

  programs.ssh.matchBlocks."ha.sc.spott.us".host = "ha.sc.spott.us";
  programs.ssh.matchBlocks."ha.sc.spott.us".user = "root";
}
