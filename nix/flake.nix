{
  description = "Home Manager configuration of Spott";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    runpodctl = {
      url = "path:/Users/spott/Documents/code/my_code/flakes/runpod";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nix-vscode-extensions,
    runpodctl,
    nix-darwin,
    nix-rosetta-builder,
    ...
  }: let
    overlay-unstable = final: prev: {
      unstable = import nixpkgs {
        system = prev.system;
        config.allowUnfree = true;
      };
    };
    overlays = [
      overlay-unstable
      nix-vscode-extensions.overlays.default
      runpodctl.overlays.default
    ];

    pkgs = system:
      import nixpkgs-stable {
        inherit system overlays;
        config = {allowUnfree = true;};
      };
  in {
    darwinConfigurations = {
      "Normandy" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = pkgs "aarch64-darwin";
        modules = [
          # nix-rosetta-builder.darwinModules.default
          ./nixdarwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.spott = {
              imports = [
                ./normandy.nix
              ];
            };
          }
        ];
      };
    };
    homeConfigurations = {
      "spott@Normandy.local" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs "aarch64-darwin";
        modules = [
          ./normandy.nix
        ];
      };

      "spott@devbox.sc.spott.us" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs "x86_64-linux";
        modules = [
          ./devbox.nix
        ];
      };
    };
    homeManagerModules = {
      devbox = import ./devbox.nix;
    };
    overlays = overlays;
  };
}
