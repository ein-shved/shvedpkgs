{ config, nixos-wsl, ... }:
{
  imports = [
    nixos-wsl.nixosModules.default
  ];
  config = {
    wsl.enable = true;
    wsl.defaultUser = config.user.name;
    wsl.tarball.configPath = ./root-config;
    wsl.startMenuLaunchers = true;

    networking.hostName = "ShvedWsl"; # Define your hostname.
    time.timeZone = "Europe/Moscow";

    system.stateVersion = "25.11";
  };
}
