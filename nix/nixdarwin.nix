{
  config,
  pkgs,
  ...
}: {
  # Nix configuration ------------------------------------------------------------------------------
  users = {
    users = {
      spott = {
        shell = pkgs.zsh;
        home = "/Users/spott";
      };
    };
  };
  /*
     nix.settings.binaryCaches = [
    "https://cache.nixos.org/"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  */
  nix.settings.trusted-users = [
    "@admin"
  ];
  #users.nix.configureBuildUsers = true;

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
  #programs.zsh.enable = true;

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
  homebrew.enable = true;
  homebrew.casks = [
    "1password-cli"
    "dash"
    "iterm2"
    "obsidian"
  ];
  homebrew.taps = [
    "1password/tap"
    "homebrew/bundle"
    "homebrew/cask"
    "homebrew/core"
  ];
}
