# get the file:
curl -fsSL "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh" > temp.sh
chmod u+x temp.sh
./temp.sh
rm ./temp.sh
