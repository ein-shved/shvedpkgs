{ config, system, ... }:
let
  domainHost = config.kl.domain.host;
  userName = config.user.name;
in
{
  imports = [
    ./hardware-configuration.nix
    ./desktop
  ];

  hardware.isLaptop = true;

  kl = {
    enable = true;
    remote.enable = true;
    domain.enable = false;
  };
  environment.printing3d.enable = true;

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    #version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
  ];

  networking.hostName = "Shvedov-NB"; # Define your hostname.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # This is low-perf laptop - so ship build tasks to my high-perf domain host.
  nix = {
    settings.sandbox = false;
    settings.substituters = [
      "ssh://${userName}@${domainHost}"
    ];
    settings.trusted-public-keys = [
      "Shvedov-1:QBukW9vSF9MfT8wE5WJ57iAD3ITvLXIFmGw6vDGfRRA="
    ];
    buildMachines = [
      {
        hostName = domainHost;
        sshUser = userName;
        inherit system;
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
  system.stateVersion = "23.05"; # Did you read the comment?

}
