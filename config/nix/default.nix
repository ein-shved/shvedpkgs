{
  config,
  lib,
  system,
  pkgs,
  ...
}:
let
  domainHost = config.kl.domain.host;
  userName = config.user.name;
  domainUrl = "ssh://${userName}@${domainHost}";
in
{
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
  nix = {
    sshServe.enable = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://hyprland.cachix.org"
      ] ++ (lib.lists.optional config.kl.remote.enable domainUrl);
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      trusted-users = [ config.user.name ];
      secret-key-files = "/etc/nix/private-key";
      builders-use-substitutes = true;
    };
    distributedBuilds = true;
    buildMachines = lib.lists.optional config.kl.remote.enable {
      hostName = domainHost;
      sshUser = userName;
      inherit system;
      supportedFeatures = [ "nixos-test" "kvm" "big-parallel" ];
      speedFactor = 4;
      maxJobs = 24;
    };
  };
}
