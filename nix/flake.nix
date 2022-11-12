{
  description = "Home Manager configuration of Spott";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";
    #nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let 
      system = "aarch64-darwin";
      #pkgs = nixpkgs;
      #nixpkgs.config = { allowUnfree = true; };
      pkgs = import nixpkgs { inherit system;
                              config = {allowUnfree = true;};
                              };
      #nixpkgs.legacyPackages.${system};

      nixpkgsConfig = {
        config = { allowUnfree = true; };
      };
    in {
      homeConfigurations."spott@Normandy.local" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./normandy.nix
          ./common.nix
          ./zsh/zsh.nix
        ];
      };
      homeConfigurations."spott@Endeavor.local" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./endeavor.nix
          ./common.nix
          ./zsh/zsh.nix
        ];
      };
    };
}
