{ config, pkgs, ... }:
let
  gamingHost = "192.168.92.201";
  userName = config.user.name;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.isNas = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ShvedMedia"; # Define your hostname.

  time.timeZone = "Europe/Moscow";


  # This is low-perf NAS server based on integrated board for media tasks - so
  # ship build tasks to my high-perf gaming host.
  nix = {
    settings.sandbox = false;
    settings.substituters = [
      "ssh://${userName}@${gamingHost}"
    ];
    settings.trusted-public-keys = [
      "ShvedGaming-1:jGkcyY1EtcKsPrXiHnagfrYR8knXQY/FJ+w6yVdn/gw="
    ];
    buildMachines = [
      {
        hostName = gamingHost;
        sshUser = userName;
        inherit (pkgs.stdenv) system;
        supportedFeatures = [
          "nixos-test"
          "kvm"
          "big-parallel"
        ];
        speedFactor = 4;
        maxJobs = 24;
      }
    ];
  };

  services.mediaStore = "/media";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

