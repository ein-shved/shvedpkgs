{ config, lib, ... }:
{
  config = {
    services = {
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
      plymouth.enable = config.hardware.isGraphic;
      kernelParams = [ "quiet" ];
      supportedFilesystems = lib.mkIf config.hardware.isGraphic [ "ntfs" ];
      binfmt.emulatedSystems = lib.optionals config.hardware.isDevelopment [
        "aarch64-linux"
      ];
    };
    documentation = {
      enable = config.hardware.isDevelopment;
      man.enable = config.hardware.isDevelopment;
      doc.enable = config.hardware.isDevelopment;
      info.enable = config.hardware.isDevelopment;
    };
    documentation.nixos = lib.mkIf config.hardware.isDevelopment {
      includeAllModules = true;
      options.warningsAreErrors = false;
    };
    systemd.services = lib.mkIf config.hardware.isDevelopment {
      nix-daemon.environment.TMPDIR = "/home/.nix-build";
      make-nix-build = {
        script = ''
          mkdir -p /home/.nix-build
        '';
        wantedBy = [ "nix-daemon.service" ];
        before = [ "nix-daemon.service" ];
      };
    };
  };
}
