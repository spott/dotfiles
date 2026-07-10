{pkgs, ...}: {
  home.packages = with pkgs; [
    unstable.docker-client
    docker-compose
    docker-buildx
    dive
    oxker
    lazydocker
  ];
}
