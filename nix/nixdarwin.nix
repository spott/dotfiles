{
    ...
}: {
# Nix configuration ------------------------------------------------------------------------------
  users = {
    users = {
      spott = {
        home = "/Users/spott";
      };
    };
  };
  system.stateVersion = 5;
  nix.settings.extra-platforms = [ "x86_64-darwin" ];
  nix.settings.substituters = [
  "https://cache.nixos.org/"
  "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.settings.trusted-users = [
    "@admin" "spott"
  ];
  nix.settings.builders-use-substitutes = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    '';
  
  nix.linux-builder = {
    enable = true;
    systems = [ "aarch64-linux" ];
    ephemeral = true;
    maxJobs = 4;
  };
  
  nix.buildMachines = [
  {
    hostName = "10.42.0.107";
    supportedFeatures = [ "kvm" ];
    maxJobs = 10;
    protocol = "ssh-ng";
    speedFactor = 1;
    sshUser = "spott";
    sshKey = "/Users/spott/.ssh/spott.sc.spott.us.pub";
    system = "x86_64-linux";
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

  system.defaults.dock.persistent-apps = [
  { app = "/Applications/Launchpad.app"; }
    #{ spacer = { small = false; }; }
  ];
  system.defaults.dock.persistent-others = [ "~/Downloads" ];


  system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
  system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;

  #system.defaults.NSGlobalDomain.NSTextShowsControlCharacters = true;
  system.defaults.NSGlobalDomain.NSTableViewDefaultSizeMode = 1;

  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;

# Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  # this is necessary to work with zimfw
  programs.zsh.enableCompletion = false;

  programs.nix-index.enable = true;
  #users.nix.configureBuildUsers = true;


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
# homebrew.enable = true;
# homebrew.casks = [
#   "1password-cli"
#   "dash"
#   "iterm2"
#   "obsidian"
# ];
# homebrew.taps = [
#   "1password/tap"
#   "homebrew/bundle"
#   "homebrew/cask"
#   "homebrew/core"
# ];
}
