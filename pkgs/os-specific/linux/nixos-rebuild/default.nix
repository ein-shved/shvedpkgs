# Wrappers for nixos-rebuild script
{ lib, ... }:
lib.mkOverlay (
  { writeShellApplication, nixos-rebuild, jq, ... }:
  {
    nixos = writeShellApplication {
      name = "nixos";
      runtimeInputs = [ nixos-rebuild jq ];
      text = ''
        UPDATE=""
        if [ "$#" -gt 0 ] && [ "$1" == "-u" ]; then
          UPDATE="1";
          shift
          if [ "$#" -gt 0 ] && [ "$1" == "--" ]; then
            shift
          fi
        fi

        if [ -n "$UPDATE" ]; then
          cd /etc/nixos/
          nix flake update
        fi

        REMOTE_SUDO=()
        if [ "$UID" != 0 ]; then
          REMOTE_SUDO=("--use-remote-sudo")
        fi

        exec nixos-rebuild "''${REMOTE_SUDO[@]}" "$@"
      '';
    };
  }
)
