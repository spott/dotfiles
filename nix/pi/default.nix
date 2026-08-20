{
  config,
  lib,
  pkgs,
  piTaskCompaction,
  ...
}: let
  mcpAdapter = "npm:pi-mcp-adapter@2.20.1";
  rpivTodo = "npm:@juicesharp/rpiv-todo@2.4.0";
  hashline = "npm:pi-hashline@0.2.0";
  system = pkgs.stdenv.hostPlatform.system;
in {
  # Pi uses npm to install packages declared in settings.json.
  home.packages = [pkgs.nodejs];

  programs.pi.coding-agent = {
    enable = true;
    rules = lib.concatStringsSep "\n\n" [
      (builtins.readFile ./lede.md)
      (builtins.readFile ./rules.md)
    ];
    extensions = [
      ./extensions/modal-editor.ts
      ./extensions/statusline.ts
      ./extensions/system-prompt.ts
      "${piTaskCompaction.packages.${system}.default}"
    ];
  };

  xdg.configFile."mcp/mcp.json" = {
    source = ./mcp.json;
    force = true;
  };

  # Preserve settings that Pi owns while declaratively ensuring required npm
  # packages are present. Keeping settings.json mutable allows Pi to save model,
  # theme, and changelog preferences normally.
  home.activation.piPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settings_path="${config.home.homeDirectory}/.pi/agent/settings.json"
    settings_dir="$(dirname "$settings_path")"

    mkdir -p "$settings_dir"
    if [[ ! -e "$settings_path" ]]; then
      printf '{}\n' > "$settings_path"
      chmod 0600 "$settings_path"
    fi

    tmp="$(mktemp "$settings_dir/settings.json.XXXXXX")"
    ${pkgs.jq}/bin/jq \
      --arg mcp_adapter '${mcpAdapter}' \
      --arg rpiv_todo '${rpivTodo}' \
      --arg hashline '${hashline}' '
      .packages = (
        [(.packages // [])[]
          | select(
              if type == "string" then
                . != "npm:pi-mcp-adapter" and
                (startswith("npm:pi-mcp-adapter@") | not) and
                . != "npm:@juicesharp/rpiv-todo" and
                (startswith("npm:@juicesharp/rpiv-todo@") | not) and
                . != "npm:pi-hashline" and
                (startswith("npm:pi-hashline@") | not) and
                . != "git:github.com/spott/pi-task-compaction" and
                (startswith("git:github.com/spott/pi-task-compaction@") | not) and
                . != "https://github.com/spott/pi-task-compaction" and
                (startswith("https://github.com/spott/pi-task-compaction@") | not)
              else
                true
              end
            )
        ] + [$mcp_adapter, $rpiv_todo, $hashline]
      )
    ' "$settings_path" > "$tmp"

    if cmp -s "$settings_path" "$tmp"; then
      rm "$tmp"
    else
      chmod 0600 "$tmp"
      mv "$tmp" "$settings_path"
    fi
  '';
}
