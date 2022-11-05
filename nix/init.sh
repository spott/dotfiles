curl -L https://nixos.org/nix/install | sh

nix build --no-link .\#homeConfigurations.spott.activationPackage
"$(nix path-info .\#homeConfigurations.spott.activationPackage)"/activate

# after install:
# home-manager switch --flake "path:.#spott"
#
# allow running x86_64 code
#sudo softwareupdate --install-rosetta --agree-to-license 
#
# to install paq on nvim
# nvim --headless -u NONE -c 'lua require("bootstrap").bootstrap_paq()'
