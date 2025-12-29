{
  config,
  pkgs,
  lib,
  isHomeManager,
  ...
}:
{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ config.user.name ];
      builders-use-substitutes = true;
    }
    // lib.optionalAttrs (!isHomeManager) {
      secret-key-files = "/etc/nix/private-key";
    };
    package = pkgs.nix;
  }
  // lib.optionalAttrs (!isHomeManager) {
    sshServe.enable = true;
    distributedBuilds = true;
  };
}
// lib.optionalAttrs (!isHomeManager) {
  systemd.services.generate-nix-cache-key = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.nix ];
    script = ''
      [[ -f /etc/nix/private-key ]] && exit
      nix-store --generate-binary-cache-key ${config.networking.hostName}-1 \
        /etc/nix/private-key /etc/nix/public-key
    '';
  };
}
