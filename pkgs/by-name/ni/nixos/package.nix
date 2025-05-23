{
  writeShellApplication,
  nixos-rebuild,
}:
writeShellApplication {
  name = "nixos";
  runtimeInputs = [
    nixos-rebuild
  ];
  text = ''
    rm -f /etc/nixos/flake.lock

    REMOTE_SUDO=()
    if [ "$UID" != 0 ]; then
      REMOTE_SUDO=("--use-remote-sudo")
    fi

    exec nixos-rebuild "''${REMOTE_SUDO[@]}" "$@"
  '';
}
