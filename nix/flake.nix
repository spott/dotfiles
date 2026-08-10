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

    # Zsh plugins are non-flake sources. flake.lock owns their revisions; the
    # repository-local Home Manager module only links and loads them.
    zsh-plugin-completion = {url = "github:zimfw/completion"; flake = false;};
    zsh-plugin-duration-info = {url = "github:zimfw/duration-info"; flake = false;};
    zsh-plugin-environment = {url = "github:zimfw/environment"; flake = false;};
    zsh-plugin-git-info = {url = "github:zimfw/git-info"; flake = false;};
    zsh-plugin-input = {url = "github:zimfw/input"; flake = false;};
    zsh-plugin-magic-enter = {url = "github:zimfw/magic-enter"; flake = false;};
    zsh-plugin-minimal = {url = "github:zimfw/minimal"; flake = false;};
    zsh-plugin-per-directory-history = {url = "github:spott/per-directory-history"; flake = false;};
    zsh-plugin-prompt-pwd = {url = "github:zimfw/prompt-pwd"; flake = false;};
    zsh-plugin-termtitle = {url = "github:zimfw/termtitle"; flake = false;};
    zsh-plugin-utility = {url = "github:zimfw/utility"; flake = false;};
    zsh-plugin-walltime = {url = "github:spott/walltime"; flake = false;};
    zsh-plugin-zimfw-eza = {url = "github:spott/zimfw-eza"; flake = false;};
    zsh-plugin-zsh-autosuggestions = {url = "github:zsh-users/zsh-autosuggestions"; flake = false;};
    zsh-plugin-zsh-completions = {url = "github:zsh-users/zsh-completions"; flake = false;};
    zsh-plugin-zsh-history-substring-search = {url = "github:zsh-users/zsh-history-substring-search"; flake = false;};
    zsh-plugin-zsh-syntax-highlighting = {url = "github:zsh-users/zsh-syntax-highlighting"; flake = false;};
    zsh-plugin-zsh-vi-mode = {url = "github:jeffreytse/zsh-vi-mode"; flake = false;};
  };

  outputs = inputs @ {
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
    zshSources = {
      completion = inputs.zsh-plugin-completion;
      duration-info = inputs.zsh-plugin-duration-info;
      environment = inputs.zsh-plugin-environment;
      git-info = inputs.zsh-plugin-git-info;
      input = inputs.zsh-plugin-input;
      magic-enter = inputs.zsh-plugin-magic-enter;
      minimal = inputs.zsh-plugin-minimal;
      per-directory-history = inputs.zsh-plugin-per-directory-history;
      prompt-pwd = inputs.zsh-plugin-prompt-pwd;
      termtitle = inputs.zsh-plugin-termtitle;
      utility = inputs.zsh-plugin-utility;
      walltime = inputs.zsh-plugin-walltime;
      zimfw-eza = inputs.zsh-plugin-zimfw-eza;
      zsh-autosuggestions = inputs.zsh-plugin-zsh-autosuggestions;
      zsh-completions = inputs.zsh-plugin-zsh-completions;
      zsh-history-substring-search = inputs.zsh-plugin-zsh-history-substring-search;
      zsh-syntax-highlighting = inputs.zsh-plugin-zsh-syntax-highlighting;
      zsh-vi-mode = inputs.zsh-plugin-zsh-vi-mode;
    };

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
            home-manager.extraSpecialArgs = {inherit zshSources;};
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
        extraSpecialArgs = {inherit zshSources;};
      };

      "spott@devbox.sc.spott.us" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs "x86_64-linux";
        modules = [
          ./devbox.nix
        ];
        extraSpecialArgs = {inherit zshSources;};
      };
    };
    homeManagerModules = {
      devbox = {pkgs, ...}: {
        imports = [
          (import ./devbox.nix)
        ];
        _module.args = {inherit zshSources;};
        dotfiles.claude-code.package = claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
    };
    overlays = overlays;
  };
}
