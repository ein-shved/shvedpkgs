{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  user.name = "gerrit-admin";
  user.humanName = "The Gerrit";
  networking.hostName = "gerrit";
  hardware.isVps = true;

  boot.loader.grub.enable = true;

  services.openssh.settings.PasswordAuthentication = false;
  security.sudo.wheelNeedsPassword = false;

  services.gerrit.serverId = "eb51f2e0-b0ea-48df-9e96-c17042d1c7c2";

  system.stateVersion = "25.11";
}
