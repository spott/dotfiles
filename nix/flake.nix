{
  description = "Home Manager configuration of Spott";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";

    # Pinned solely to supply the lima build recipe for nix-rosetta-builder.
    # It must stay version-matched to the lima fork that spott/nix-rosetta-builder
    # points at (currently v2.2.0) -- the module overrides lima's src but inherits
    # this recipe, so a skewed pair stamps the wrong version into the binary.
    # Bump this and the fork's rebase base together, never separately.
    nixpkgs-lima.url = "github:nixos/nixpkgs/104240a772428cc2e20d8fd86c9ddbb886bbaff2";

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

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
    };

    tuicr = {
      url = "github:spott/tuicr/per-commit-review-workflow";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Fork of cpick/nix-rosetta-builder pinned to a lima 2.2.0-based patch set.
    # Upstream still builds cpick/lima@afbfdfb (lima v1.0.2, Dec 2024), whose
    # dependency tree has 39 govulncheck-reachable advisories. See spott/lima
    # and spott/gvisor-tap-vsock, branch `launchd-socket-activation`.
    nix-rosetta-builder = {
      url = "github:spott/nix-rosetta-builder/lima-2.x";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-lima,
    home-manager,
    nix-vscode-extensions,
    claude-code-nix,
    nix-darwin,
    nix-rosetta-builder,
    nvim-treesitter-main,
    tuicr,
    ...
  }: let
    overlay-unstable = final: prev: {
      unstable = import nixpkgs {
        system = prev.system;
        config.allowUnfree = true;
        overlays = [
          claude-code-nix.overlays.default
          nvim-treesitter-main.overlays.default
          (final: prev: {
            python312 = prev.python312.override {
              packageOverrides = pyFinal: pyPrev: {
                debugpy = pyPrev.debugpy.overrideAttrs (_: {
                  # Skip debugpy's test suite and its large check-only dependencies.
                  doInstallCheck = false;
                });
              };
            };
          })
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
    overlay-tuicr = final: prev: {
      tuicr = tuicr.packages.${prev.stdenv.hostPlatform.system}.default;
    };
    # nix-rosetta-builder overrides lima's src with a patched fork but inherits
    # nixpkgs' lima recipe. Our fork is rebased onto v2.2.0, so the recipe has to
    # be 2.x too -- nixpkgs-stable still ships 1.2.2 (EOL, and a mismatched build).
    overlay-lima = final: prev: {
      lima =
        (import nixpkgs-lima {
          inherit (prev.stdenv.hostPlatform) system;
        })
        .lima;
    };
    overlays = [
      overlay-unstable
      overlay-inetutils-darwin
      overlay-tuicr
      overlay-lima
      #pylsp-rope.overlays.default
      nix-vscode-extensions.overlays.default
      claude-code-nix.overlays.default
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
          nix-rosetta-builder.darwinModules.default
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
      devbox = {pkgs, ...}: {
        imports = [
          (import ./devbox.nix)
        ];
        dotfiles.claude-code.package = claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
    };
    overlays = overlays;
  };
}
