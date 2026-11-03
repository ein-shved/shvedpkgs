{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./desktop
  ];

  home.enable = true;
  hardware.isVpsClient = true;
  hardware.isGraphic = true;
  hardware.isDevelopment = true;

  kl.enable = false;
  environment = {
    printing3d.enable = true;
    gaming.enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ShvedGaming"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    # Preserve VRAM and run the NVIDIA suspend/resume hooks around system sleep.
    powerManagement.enable = true;
    # /tmp is a tmpfs smaller than this GPU's 8 GiB of VRAM.
    moduleParams.nvidia.NVreg_TemporaryFilePath = "/var/tmp";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
