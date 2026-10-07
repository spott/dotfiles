{pkgs, ...}: {
  home.packages = with pkgs; [
    bat # need to install this, as home-manager on nixos doesn't seem to install packages if you enable them?
    delta
    bottom
    dust
    fd
    duf
    doggo # replaces dogdns, removed from nixpkgs 26.05
    ripgrep
    eza
    age
    xh

    # standard utils:
    findutils
    inetutils
    jq
    yq
    git
    git-lfs
    just
    cmake

    # fancy output
    glow

    # for ssh
    mosh
  ];
}
