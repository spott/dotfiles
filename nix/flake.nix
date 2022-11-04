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
      pkgs = nixpkgs.legacyPackages.${system};

      nixpkgsConfig = {
        config = { allowUnfree = true; };
      };
    in {
      homeConfigurations.spott = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];
      };
      /* darwinConfigurations."Endeavor" = darwin.lib.darwinSystem {
        inherit system;
        modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
          {
            #nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
	    home-manager.verbose = true;
            home-manager.users.spott = import ./home.nix;            
          }
        ];
      }; */
    };

    /* let
      username = "spott";
      email = "andrew.spott@submittable.com";

      config = {
        configuration = import ./home.nix;
        inherit username;
        stateVersion = "22.05";
      };
      # system = "aarch64-darwin":
      # pkgs = nixpkgs.legacyPackages.${system};
    in {
        homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration (config // {system = "aarch64-darwin";});

      #homeConfigurations.spott = home-manager.lib.homeManagerConfiguration
    }; */
}
