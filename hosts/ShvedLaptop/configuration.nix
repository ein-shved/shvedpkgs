{ config, pkgs, ... }:
let
  gamingHost = "192.168.92.201";
  userName = config.user.name;
in
{
  imports = [
    ./hardware-configuration.nix
    ./desktop
  ];

  hardware.isLaptop = true;

  kl.enable = false;
  environment.printing3d.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
  ];

  networking.hostName = "ShvedLaptop"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # This is ancient slow laptop - so ship build tasks to my high-perf
  # gaming host.
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
