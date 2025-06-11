{pkgs, ...}: {
  home.packages = with pkgs; [
    viu
    imagemagick
    timg
  ];
}
