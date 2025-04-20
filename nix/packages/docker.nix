{pkgs, ...}: {
  home.packages = with pkgs; [
    docker-client
    docker-compose
    docker-buildx
    dive
    oxker
    lazydocker
  ];
}
