{pkgs,...}: {
  home.packages = with pkgs; [
    skimpdf
    unstable.klayout
  ];
}
