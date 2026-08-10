{
  config,
  lib,
  pkgs,
  ...
}: let
  mcpAdapter = "npm:pi-mcp-adapter@2.20.1";
in {
  # Pi uses npm to install packages declared in settings.json.
  home.packages = [pkgs.nodejs];

  home.file.".pi/agent/extensions/modal-editor.ts" = {
    source = ./extensions/modal-editor.ts;
    force = true;
  };

  home.file.".pi/agent/extensions/system-prompt.ts" = {
    source = ./extensions/system-prompt.ts;
    force = true;
  };

  xdg.configFile."mcp/mcp.json" = {
    source = ./mcp.json;
    force = true;
  };

  # Preserve settings that Pi owns while declaratively ensuring that the
  # pinned MCP adapter is present. Keeping settings.json mutable allows Pi to
  # save model, theme, and changelog preferences normally.
  home.activation.piPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settings_path="${config.home.homeDirectory}/.pi/agent/settings.json"
    settings_dir="$(dirname "$settings_path")"
    desired_package='${mcpAdapter}'

    mkdir -p "$settings_dir"
    if [[ ! -e "$settings_path" ]]; then
      printf '{}\n' > "$settings_path"
      chmod 0600 "$settings_path"
    fi

    tmp="$(mktemp "$settings_dir/settings.json.XXXXXX")"
    ${pkgs.jq}/bin/jq --arg desired "$desired_package" '
      .packages = (
        [(.packages // [])[]
          | select(
              if type == "string" then
                . != "npm:pi-mcp-adapter" and
                (startswith("npm:pi-mcp-adapter@") | not)
              else
                true
              end
            )
        ] + [$desired]
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
