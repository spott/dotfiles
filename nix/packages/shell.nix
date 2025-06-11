{pkgs, ...}: {
  home.packages = with pkgs; [
    #bat
    delta
    bottom
    du-dust
    fd
    duf
    dogdns
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
  ];
}
