{
  lib,
  pkgs,
  ...
}: {
  #
  # SSH
  #
  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;

  # dstack
  programs.ssh.includes = ["~/.dstack/ssh/config" "~/.orbstack/ssh/config"];
  programs.ssh.extraConfig = "SetEnv TERM=\"xterm-color\"";

  # Attribute names are `Host` patterns; values use upstream ssh_config(5)
  # directive names. `Host *` is ordered last so the specific blocks win.
  programs.ssh.settings = {
    # Sandbox users
    "sandbox-ai" = {
      HostName = "localhost";
      User = "sandbox-ai";
      # 1Password agent handles key via IdentityAgent
    };

    # for home network, needs to be behind an option to prevent it being used on other comps
    "moneta 10.42.1.2" = {
      HostName = "10.42.1.2";
      IdentityFile = ["~/.ssh/spott.moneta.pub" "~/.ssh/ansible.moneta.pub" "~/.ssh/root.moneta.pub"];
      IdentitiesOnly = true;
    };

    "nix-build 10.42.0.107" = {
      HostName = "10.42.0.107";
      IdentityFile = ["~/.ssh/spott.sc.spott.us.pub"];
      IdentitiesOnly = true;
    };

    "lm.emodephotonix.com" = {
      HostName = "lm.emodephotonix.com";
      IdentityFile = ["~/.ssh/lm-server.pub"];
      IdentitiesOnly = true;
      User = "emode";
    };

    "github.com" = {
      User = "git";
      ControlMaster = "no";
    };
    # for git:
    # "github.com".IdentitiesOnly = true;
    # "github.com".IdentityCommand = ''sh -c 'op read "op://bkmk.io/deploy key/private key?ssh-format=openssh"' '';

    "*" = lib.hm.dag.entryAfter ["sandbox-ai" "moneta 10.42.1.2" "nix-build 10.42.0.107" "lm.emodephotonix.com" "github.com"] {
      ControlMaster = "auto";
      ControlPersist = "30m";
      ControlPath = "~/.cache/ssh/master-%r@%n:%p";
    };
  };
}
