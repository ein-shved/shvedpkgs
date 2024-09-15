{ config, lib, system, ... }:
let
  domainHost = config.kl.domain.host;
  userName = config.user.name;
  home = config.user.home;
  domainUrl = "ssh://${userName}@${domainHost}";
in
{
  nix = {
    sshServe.enable = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://hyprland.cachix.org" ] ++
        (lib.lists.optional config.kl.remote.enable domainUrl);
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      trusted-users = [ config.user.name ];
    };
    distributedBuilds = true;
    buildMachines = lib.lists.optional config.kl.remote.enable {
      hostName = domainHost;
      sshUser = userName;
      inherit system;
    };
  };
}
