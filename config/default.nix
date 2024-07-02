{ config, lib, ... }:
{
  imports = [
    ./allowance.nix
    ./applications
    ./bashrc
    ./desktop
    ./exceptions
    ./media
    ./services
    ./tools
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
    nix.sshServe.enable = true;
    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    documentation.nixos = {
      includeAllModules = true;
      options.warningsAreErrors = false;
    };
    systemd.services = {
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
