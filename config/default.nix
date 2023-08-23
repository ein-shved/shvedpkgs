{ config, ... }:
{
  imports = [
    ./allowance.nix
    ./applications
    ./bashrc
    ./desktop
    ./media
    ./tools
    ./services
  ];
  config = {
    services = {
      printing.enable = true;
      blueman.enable = config.hardware.bluetooth.enable;
      openssh = {
        enable = true;
      };
    };
    networking.networkmanager.enable = true;
    boot = {
      tmp = {
        useTmpfs = true;
        cleanOnBoot = true;
      };
      plymouth.enable = true;
      kernelParams = [ "quiet" ];
      supportedFilesystems = [ "ntfs" ];
      binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
    systemd.services.nix-daemon.environment.TMPDIR = "/home/.nix-build";
    nix.settings.auto-optimise-store = true;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixpkgs.config.permittedInsecurePackages = [
      # TODO remove this after getting rid of outdated packages.
      # Known packages are:
      # pcsc-safenet
      # pcsc-safenet-legacy
      # pcsclite
      "openssl-1.1.1u"
      "openssl-1.1.1v"
    ];
  };
}
