{pkgs, ...}: {
  # 1password config
  xdg.configFile."1Password/ssh/agent.toml".source = ./agent.toml;

  home.packages = [pkgs._1password-cli];
}
