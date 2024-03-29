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
#
# For touchid for sudo in terminal:
# add 'auth sufficient pam_tid.so' to the top of /etc/pam/sudo
#
# If zimrc is changed:
# zimfw install
#
# Generate brewfile
# brew bundle dump
#
# install onepassword plugin for homebrew:
# https://developer.1password.com/docs/cli/shell-plugins/homebrew/
