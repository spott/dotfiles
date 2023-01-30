{
  description = "Home Manager configuration of Spott";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    /*
       flake-utils = {
      url = "github:numtide/flake-utils";
    };
    */
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }:
  #flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux flake-utils.lib.system.aarch64-darwin ] (system:
  let
    #system = "aarch64-darwin";
    #system = "x86_64-linux";
    pkgs = sys:
      import nixpkgs {
        system = sys;
        config = {allowUnfree = true;};
      };
  in {
    packages = {
      aarch64-darwin.homeConfigurations = {
        "spott@Normandy.local" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs "aarch64-darwin";
          modules = [
            ./normandy.nix
            ./common.nix
            ./darwin-common.nix
            ./zsh/zsh.nix
          ];
        };
        "spott@Endeavor.local" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs "aarch64-darwin";
          modules = [
            ./endeavor.nix
            ./common.nix
            ./darwin-common.nix
            ./zsh/zsh.nix
          ];
        };
      };
      x86_64-linux.homeConfigurations = {
        "spott@devbox" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs "x86_64-linux";
          modules = [
            ./devbox.nix
            ./common.nix
            ./zsh/zsh.nix
          ];
        };
      };
    };
  };
}
