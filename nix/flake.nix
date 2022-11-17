{
  description = "Home Manager configuration of Spott";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux flake-utils.lib.system.aarch64-darwin ] (system: 
    let 
      #system = "aarch64-darwin";
      #system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system;
                              config = {allowUnfree = true;};
                              };
    in {
      homeConfigurations."spott@Normandy.local" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs system;
        modules = [
          ./normandy.nix
          ./common.nix
          ./darwin-common.nix
          ./zsh/zsh.nix
        ];
      };
      homeConfigurations."spott@Endeavor.local" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs system;
        modules = [
          ./endeavor.nix
          ./common.nix
          ./darwin-common.nix
          ./zsh/zsh.nix
        ];
      };
      homeConfigurations."spott@devbox" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs system;
        modules = [
          ./devbox.nix
          ./common.nix
          ./zsh/zsh.nix
        ];
      };
    }
  );
}
