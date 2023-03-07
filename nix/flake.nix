{
  description = "Home Manager configuration of Spott";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
    nixpkgs-unstable,
    home-manager,
    ...
  }:
  #flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux flake-utils.lib.system.aarch64-darwin ] (system:
  let
    #system = "aarch64-darwin";
    #system = "x86_64-linux";
    unstable-pkgs = sys:
      import nixpkgs-unstable {
        system = sys;
        config = {allowUnfree = true;};
      };
      
    overlays = sys: [
        (self: super: {
          python = super.python310;
          pulumi = (unstable-pkgs sys).pulumi;
          pulumi-bin = (unstable-pkgs sys).pulumi-bin;
        })
      ];
      
    pkgs = sys:
      import nixpkgs {
        system = sys;
        config = {allowUnfree = true;};
        overlays = overlays sys;
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
