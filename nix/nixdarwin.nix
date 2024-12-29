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
  nix.settings.extra-platforms = [ "aarch64-linux" ];
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
  ];
#users.nix.configureBuildUsers = true;

  # nix.buildMachines = [
  # {
  #   hostName = "10.42.0.107";
  #   supportedFeatures = [ "kvm" ];
  #   maxJobs = 10;
  #   protocol = "ssh-ng";
  #   speedFactor = 1;
  #   sshUser = "spott";
  #   system = "x86_64-linux";
  # }
  # ];

  # nix.configureBuildUsers = true;

  # nix.linux-builder = {
  #   enable = true;
  #   systems = [ "aarch64-linux" ];
  #
  # };

  nixpkgs.config = {
    allowUnfree = true;
  };


# Enable experimental nix command and flakes
# nix.package = pkgs.nixUnstable;
# '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
# auto-optimise-store = true
# extra-platforms = x86_64-darwin aarch64-darwin
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    '';
#

# Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

# Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  programs.nix-index.enable = true;

# Fonts
  /*
     fonts.enableFontDir = true;
     fonts.fonts = with pkgs; [
     recursive
     (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
     ];
   */

# Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

# Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

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
