# Wrappers for nixos-rebuild script
{ lib, ... }:
lib.mkOverlay (
  { writeShellApplication, nixos-rebuild, jq, ... }:
  {
    nixos = writeShellApplication {
      name = "nixos";
      runtimeInputs = [ nixos-rebuild jq ];
      text = ''
        cd /etc/nixos/
        nix flake update

        REMOTE_SUDO=()
        if [ "$UID" != 0 ]; then
          REMOTE_SUDO=("--use-remote-sudo")
        fi

        exec nixos-rebuild "''${REMOTE_SUDO[@]}" "$@"
      '';
    };
  }
)
