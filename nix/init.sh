curl -L https://nixos.org/nix/install | sh

nix build --no-link .\#homeConfigurations.spott.activationPackage
$(nix path-info .\#homeConfigurations.spott.activationPackage)"/activate

# after install:
# home-manager switch --flake "path:.#spott"
sudo softwareupdate --install-rosetta --agree-to-license # allow running x86_64 code


