{pkgs,...}: {
  home.packages = with pkgs; [
    # rust stuff
    rustup
    dprint
    rustc
  ];
}
