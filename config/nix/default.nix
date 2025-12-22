{
  config,
  pkgs,
  lib,
  isHomeManager,
  ...
}:
{
  # systemd.services.generate-nix-cache-key = {
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.Type = "oneshot";
  #   path = [ pkgs.nix ];
  #   script = ''
  #     [[ -f /etc/nix/private-key ]] && exit
  #     nix-store --generate-binary-cache-key ${config.networking.hostName}-1 \
  #       /etc/nix/private-key /etc/nix/public-key
  #   '';
  # };
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ config.user.name ];
      secret-key-files = "/etc/nix/private-key";
      builders-use-substitutes = true;
    };
    package = pkgs.nix;
  }
  // lib.optionalAttrs (!isHomeManager) {
    sshServe.enable = true;
    distributedBuilds = true;
  };
}
