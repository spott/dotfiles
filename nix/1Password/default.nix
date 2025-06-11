{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.dotfiles._1password;
in {
  options.dotfiles._1password = {
    sshAgentConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable 1password agent.toml config";
    };
  };

  config = lib.mkMerge [
    {
      home.packages = [pkgs._1password-cli];
    }
    (lib.mkIf cfg.sshAgentConfig {
      # 1password config
      xdg.configFile."1Password/ssh/agent.toml".source = ./agent.toml;

      programs.ssh.extraConfig =
        if pkgs.stdenv.isDarwin
        then "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
        else if pkgs.stdenv.isLinux
        then "IdentityAgent \"~/.1password/agent.sock\""
        else "";
    })
  ];
}
