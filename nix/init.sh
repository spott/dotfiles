curl -L https://nixos.org/nix/install | sh

nix build --no-link .\#homeConfigurations.spott.activationPackage
$(nix path-info .\#homeConfigurations.spott.activationPackage)"/activate

# after install:
# home-manager switch --flake "path:.#spott"
