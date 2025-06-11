{pkgs, ...}: {
  #
  # SSH
  #
  programs.ssh.enable = true;
  programs.ssh.controlMaster = "auto";
  programs.ssh.controlPersist = "30m";
  programs.ssh.controlPath = "~/.cache/ssh/master-%r@%n:%p";

  # dstack
  programs.ssh.includes = ["~/.dstack/ssh/config" "~/.orbstack/ssh/config"];
  programs.ssh.extraConfig = "SetEnv TERM=\"xterm-color\"";

  # for home network, needs to be behind an option to prevent it being used on other comps
  programs.ssh.matchBlocks."10.42.1.2".host = "moneta 10.42.1.2";
  programs.ssh.matchBlocks."10.42.1.2".hostname = "10.42.1.2";
  programs.ssh.matchBlocks."10.42.1.2".identityFile = ["~/.ssh/spott.moneta.pub" "~/.ssh/ansible.moneta.pub" "~/.ssh/root.moneta.pub"];
  #programs.ssh.matchBlocks."10.42.1.2".extraOptions = {"IdentityFile" = "~/.ssh/ansible.moneta.pub";};
  programs.ssh.matchBlocks."10.42.1.2".identitiesOnly = true;

  programs.ssh.matchBlocks."10.42.0.107" = {
    host = "nix-build 10.42.0.107";
    hostname = "10.42.0.107";
    identityFile = ["~/.ssh/spott.sc.spott.us.pub"];
    identitiesOnly = true;
  };

  programs.ssh.matchBlocks."lm.emodephotonix.com" = {
    host = "lm.emodephotonix.com";
    hostname = "lm.emodephotonix.com";
    identityFile = ["~/.ssh/lm-server.pub"];
    identitiesOnly = true;
    user = "emode";
  };

  # for git:
  #programs.ssh.matchBlocks."github.com".identitiesOnly = true;
  # programs.ssh.matchBlocks."github.com".extraOptions = {
  #   identityCommand = ''
  #   sh -c 'op read "op://bkmk.io/deploy key/private key?ssh-format=openssh"'
  #   '';
  # };
}
