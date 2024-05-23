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
    /*
       flake-utils = {
      url = "github:numtide/flake-utils";
    };
    */
    #nixpkgs_stable.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nix-vscode-extensions,
    runpodctl,
    # nixpkgs_stable,
    ...
  }:
  #flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux flake-utils.lib.system.aarch64-darwin ] (system:
  let
    # pkgs_stable = system:
    #   import nixpkgs {
    #     inherit system;
    #     config = {allowUnfree= true;};
    #     };
    #system = "aarch64-darwin";
    #system = "x86_64-linux";
    # unstable-pkgs = sys:
    #   import nixpkgs-unstable {
    #     system = sys;
    #     config = {allowUnfree = true;};
    #   };
    #   
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
