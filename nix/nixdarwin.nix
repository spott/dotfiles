{pkgs,...}: {
  imports = [
    ./sandbox/darwin.nix
  ];

  # Sandbox user configuration
  sandbox = {
    enable = true;
    primaryUser = "spott";
    users = [
      {
        name = "ai";
        # Add your SSH public key from 1Password here:
        # sshPublicKey = "ssh-ed25519 AAAA...";
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeWZXJFqGzNZhGbODh6ucaqimqE8AKYowtQ2kpzAnAh";
      }
    ];
  };
  # Nix configuration ------------------------------------------------------------------------------
  users = {
    users = {
      spott = {
        home = "/Users/spott";
        shell = pkgs.zsh;
        ignoreShellProgramCheck = true;
      };
    };
  };
  system.stateVersion = 5;
  nix.settings.extra-platforms = ["x86_64-darwin"];
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.settings.trusted-users = [
    "@admin"
    "spott"
  ];
  nix.settings.builders-use-substitutes = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.linux-builder = {
    enable = true;
    systems = ["aarch64-linux"];
    ephemeral = true;
    maxJobs = 4;
  };

  environment.etc."resolver/sc.spott.us" = {
    text = ''
      nameserver 10.42.10.2
    '';
    #mode = "0644";
  };

  # nix-rosetta-builder = {
  #   cores = 8;
  #   onDemand = true;
  #   memory = "8GiB";
  #   #speedFactor = 2;
  # };

  programs.ssh.extraConfig = ''
  Host eu.nixbuild.net
    PubkeyAcceptedKeyTypes ssh-ed25519
    ServerAliveInterval 60
    IPQoS throughput
    IdentityFile /etc/nix/nixbuild
'';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix.buildMachines = [
    {
      hostName = "10.42.0.107";
      supportedFeatures = ["kvm"];
      maxJobs = 10;
      protocol = "ssh-ng";
      speedFactor = 2;
      sshUser = "spott";
      sshKey = "/Users/spott/.ssh/spott.sc.spott.us.pub";
      system = "x86_64-linux";
    }
    {
      hostName = "eu.nixbuild.net";
      system = "x86_64-linux";
      maxJobs = 100;
      speedFactor = 1;
      supportedFeatures = [ "benchmark" "big-parallel" ];
    }
    {
      hostName = "eu.nixbuild.net";
      system = "aarch64-linux";
      maxJobs = 100;
      speedFactor = 1;
      supportedFeatures = [ "benchmark" "big-parallel" ];
    }
  ];

  nix.distributedBuilds = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults.finder.ShowStatusBar = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  system.defaults.finder.AppleShowAllExtensions = true;

  system.defaults.dock.static-only = true;
  system.defaults.dock.show-recents = false;
  system.defaults.dock.scroll-to-open = true;
  system.defaults.dock.magnification = true;
  system.defaults.dock.largesize = 20;
  system.defaults.dock.autohide = true;
  system.defaults.dock.wvous-bl-corner = 13;

  system.primaryUser = "spott";

  system.defaults.dock.persistent-apps = [
    {app = "/Applications/Launchpad.app";}
    #{ spacer = { small = false; }; }
  ];
  system.defaults.dock.persistent-others = ["~/Downloads"];

  system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
  system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;

  #system.defaults.NSGlobalDomain.NSTextShowsControlCharacters = true;
  system.defaults.NSGlobalDomain.NSTableViewDefaultSizeMode = 1;

  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  # this is necessary to work with zimfw
  programs.zsh.enableCompletion = false;

  programs.nix-index.enable = true;
  #users.nix.configureBuildUsers = true;

  environment.shells = [pkgs.zsh];
  # nix.configureBuildUsers = true;

  # Fonts
  /*
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
  recursive
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  */

  # Homebrew:
  homebrew.enable = true;
  homebrew.casks = [
    "zotero"
    "windows-app"
    "viscosity"
    "raycast"
    "quicklook-json"
    "qlstephen"
    "qlmarkdown"
    "qlcolorcode"
    "orbstack"
    "orcaslicer"
    "obsidian"
    "kicad"
    "macwhisper"
    "key-codes"
    "iina"
    "gnucash"
    "ghostty"
    "firefox"
    "discord"
    "diffusionbee"
    "dash"
    "anki"
  ];
  homebrew.taps = [
    #"1password/tap"
    "homebrew/bundle"
    "homebrew/services"
  ];
}
