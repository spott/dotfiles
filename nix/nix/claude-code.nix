{pkgs, lib, config, ...}: let
  cfg = config.dotfiles.claude-code;
in {
  options.dotfiles.claude-code = {
    allowDangerousMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to skip the dangerous mode permission prompt.";
    };
  };

  config = {
    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code;

      settings = {
        skipDangerousModePermissionPrompt = cfg.allowDangerousMode;
        hooks = {
          Notification = [
            {
              matcher = "permission_prompt|idle_prompt";
              hooks = [
                {
                  type = "command";
                  command = ''jq -r '"Claude Code waiting: \(.cwd) on '$(hostname)'"' | curl -s -d @- https://ntfy.sc.spott.us/claude'';
                }
              ];
            }
          ];
        };
      };

      agents = {
        "codebase-analyzer" = ./claude-code/agents/codebase-analyzer.md;
        "codebase-locator" = ./claude-code/agents/codebase-locator.md;
      };

      commands = {
        "create-pr" = ./claude-code/commands/create-pr.md;
        "plan" = ./claude-code/commands/plan.md;
        "research" = ./claude-code/commands/research.md;
      };
    };
  };
}
