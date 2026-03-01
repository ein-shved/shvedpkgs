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
      plymouth.enable = config.hardware.needGraphic;
      kernelParams = [ "quiet" ];
      supportedFilesystems = lib.mkIf config.hardware.needGraphic [ "ntfs" ];
      binfmt.emulatedSystems = lib.optionals config.hardware.development [
        "aarch64-linux"
      ];
    };
    documentation = {
      enable = config.hardware.development;
      man.enable = config.hardware.development;
      doc.enable = config.hardware.development;
      info.enable = config.hardware.development;
    };
    documentation.nixos = lib.mkIf config.hardware.development {
      includeAllModules = true;
      options.warningsAreErrors = false;
    };
    systemd.services = lib.mkIf config.hardware.development {
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
