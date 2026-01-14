{ config, lib, pkgs, ... }:

let
  cfg = config.sandbox;
in {
  options.sandbox = {
    enable = lib.mkEnableOption "sandbox user management";

    primaryUser = lib.mkOption {
      type = lib.types.str;
      description = "The primary user who can access sandbox users";
      example = "spott";
    };

    users = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Sandbox username (will be prefixed with sandbox-)";
            example = "ai";
          };
          sshPublicKey = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "SSH public key for this sandbox user";
          };
        };
      });
      default = [];
      description = "List of sandbox users to create";
    };

  };

  config = lib.mkIf cfg.enable {
    # Add Ghostty terminfo for sandbox users
    environment.variables.TERMINFO_DIRS = lib.mkBefore [
      "/Applications/Ghostty.app/Contents/Resources/terminfo"
    ];
    # Create each sandbox user
    users.users = lib.listToAttrs (map (user: {
      name = "sandbox-${user.name}";
      value = {
        name = "sandbox-${user.name}";
        home = "/Users/sandbox-${user.name}";
        shell = pkgs.zsh;
      };
    }) cfg.users);

    # Create groups with primary user as member
    users.groups = lib.listToAttrs (map (user: {
      name = "sandbox-${user.name}";
      value = {
        members = [ cfg.primaryUser "sandbox-${user.name}" ];
      };
    }) cfg.users);

    # Sudoers for each sandbox user
    environment.etc = lib.listToAttrs (map (user: {
      name = "sudoers.d/50-sandbox-${user.name}";
      value = {
        text = ''
          ${cfg.primaryUser} ALL=(sandbox-${user.name}) NOPASSWD: ALL
        '';
        #mode = "0440";
      };
    }) cfg.users);

    # User and group creation - MUST run before home-manager
    system.activationScripts.preActivation.text = lib.concatMapStrings (user: ''
      # Create group if it doesn't exist
      if ! dscl . -read /Groups/sandbox-${user.name} &>/dev/null; then
        # Find next available GID
        NEXT_GID=$(dscl . -list /Groups PrimaryGroupID | awk '{print $2}' | sort -n | tail -1)
        NEXT_GID=$((NEXT_GID + 1))
        dscl . -create /Groups/sandbox-${user.name}
        dscl . -create /Groups/sandbox-${user.name} PrimaryGroupID $NEXT_GID
        dscl . -create /Groups/sandbox-${user.name} RealName "Sandbox ${user.name}"
      fi

      # Create user if it doesn't exist
      if ! dscl . -read /Users/sandbox-${user.name} &>/dev/null; then
        sysadminctl -addUser sandbox-${user.name} -shell /bin/zsh -home /Users/sandbox-${user.name} 2>/dev/null || true
        dscl . -create /Users/sandbox-${user.name} IsHidden 1 2>/dev/null || true
      fi

      # Add users to the group (idempotent - dscl handles duplicates)
      dscl . -append /Groups/sandbox-${user.name} GroupMembership sandbox-${user.name}
      dscl . -append /Groups/sandbox-${user.name} GroupMembership ${cfg.primaryUser}

      # Ensure home directory exists
      if [ ! -d /Users/sandbox-${user.name} ]; then
        mkdir -p /Users/sandbox-${user.name}
        chown sandbox-${user.name}:staff /Users/sandbox-${user.name}
        chmod 755 /Users/sandbox-${user.name}
      fi
    '') cfg.users;

    # Workspace and SSH setup - runs after home-manager
    system.activationScripts.postActivation.text = lib.concatMapStrings (user: ''
      # Shared workspace setup
      mkdir -p /Users/Shared/sandbox-${user.name}
      chown sandbox-${user.name}:sandbox-${user.name} /Users/Shared/sandbox-${user.name} 2>/dev/null || true
      chmod 770 /Users/Shared/sandbox-${user.name}
      /bin/chmod +a "group:sandbox-${user.name} allow read,write,append,delete,list,search,add_file,add_subdirectory,delete_child,file_inherit,directory_inherit" /Users/Shared/sandbox-${user.name} 2>/dev/null || true

      # SSH authorized_keys
      ${lib.optionalString (user.sshPublicKey != null) ''
        mkdir -p /Users/sandbox-${user.name}/.ssh
        chmod 700 /Users/sandbox-${user.name}/.ssh
        echo "${user.sshPublicKey}" > /Users/sandbox-${user.name}/.ssh/authorized_keys
        chmod 600 /Users/sandbox-${user.name}/.ssh/authorized_keys
        chown -R sandbox-${user.name}:sandbox-${user.name} /Users/sandbox-${user.name}/.ssh
      ''}
    '') cfg.users;

    # Home Manager configuration for each sandbox user
    home-manager.users = lib.listToAttrs (map (user: {
      name = "sandbox-${user.name}";
      value = {
        imports = [
          ./home.nix
        ];
        sandbox.name = user.name;
      };
    }) cfg.users);
  };
}
