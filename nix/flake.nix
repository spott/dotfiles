{
  description = "Home Manager configuration of Spott";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    runpodctl = {
      url = "path:/Users/spott/Documents/code/my_code/flakes/runpod";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nix-vscode-extensions,
    runpodctl,
    nix-darwin,
    ...
  }: let
    overlay-stable = final: prev: {
      stable = import nixpkgs-stable {
        system = prev.system;
        config.allowUnfree = true;
      };
    };
    overlays = [
      overlay-stable
      nix-vscode-extensions.overlays.default
      runpodctl.overlays.default
    ];

    pkgs = system:
      import nixpkgs {
        inherit system overlays;
        config = {allowUnfree = true;};
      };
  in {
    darwinConfigurations = {
      "Normandy" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = pkgs "aarch64-darwin";
        modules = [
          ./nixdarwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.spott = {
              imports = [
                ./normandy.nix
                # ./common.nix
                # ./darwin-common.nix
                # ./zsh
                # ./nix/vscode.nix
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

      "spott@devbox.sc.spott.us" =
        home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs "x86_64-linux";
            modules = [
              ./devbox.nix
            ];
        };
    };
  };
}
