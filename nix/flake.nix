{
  description = "Home Manager configuration of Spott";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # this is necessary now because nvim-treesitter on nixpkgs is kinda broken
    nvim-treesitter-main = {
      url = "github:iofq/nvim-treesitter-main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # runpodctl = {
    #   url = "path:/Users/spott/Documents/code/my_code/flakes/runpod";
    #   inputs.nixpkgs.follows = "nixpkgs-stable";
    # };

    # This is disabled for now, as it's not working
    # pylsp-rope = {
    #   url = "path:/Users/spott/code/others_code/pylsp-rope";
    #   inputs.nixpkgs.follows = "nixpkgs-stable";
    # };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
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
    nix-darwin,
    nix-rosetta-builder,
    nvim-treesitter-main,
    ...
  }: let
    overlay-unstable = final: prev: {
      unstable = import nixpkgs {
        system = prev.system;
        config.allowUnfree = true;
        overlays = [
          nvim-treesitter-main.overlays.default
          (final: prev: {
            vimPlugins = prev.vimPlugins.extend (
              f: p: {
                nvim-treesitter = p.nvim-treesitter.withAllGrammars; # or withPlugins...
                # also redefine nvim-treesitter-textobjects (any other plugins that depend on nvim-treesitter)
                nvim-treesitter-textobjects = p.nvim-treesitter-textobjects.overrideAttrs {
                  dependencies = [f.nvim-treesitter];
                };
                neotest = p.neotest.overrideAttrs {
                  dependencies = [f.nvim-treesitter];
                };
              }
            );
          })
        ];
      };
    };
    # https://github.com/NixOS/nixpkgs/issues/488689
    overlay-inetutils-darwin = final: prev:
      prev.lib.optionalAttrs prev.stdenv.isDarwin {
        inetutils = prev.inetutils.overrideAttrs (old: {
          hardeningDisable = (old.hardeningDisable or []) ++ ["format"];
        });
      };
    overlays = [
      overlay-unstable
      overlay-inetutils-darwin
      #pylsp-rope.overlays.default
      nix-vscode-extensions.overlays.default
      #runpodctl.overlays.default
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
