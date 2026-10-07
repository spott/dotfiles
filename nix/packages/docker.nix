{pkgs, ...}: {
  home.packages = with pkgs; [
    unstable.docker-client
    docker-compose
    docker-buildx
    dive
    # oxker  # TUI snapshot tests fail on darwin (mrjackwills/oxker#73); rarely used
    lazydocker
  ];
}
