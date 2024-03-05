{ lib, config, pkgs, ... }:
let
  cfg = config.environment.printing3d;
in
{
  options.environment.printing3d = {
    enable = lib.mkEnableOption ''
      Is current system used for 3D modelling and printing
    '';
    prusaConfig = lib.mkOption {
      type = with lib.types; nullOr (either package pathInStore);
      description = ''
        Files of PrusaSlicer configuration which will be written to
        ~/.config/PrusaSlicer/
      '';
      default = null;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.prusa-slicer
    ];
    services.kompas3d.enable = true;
    home.activations = {
      prusaConfig = if cfg.prusaConfig == null then "true" else ''
        configDir=$HOME/.config/PrusaSlicer
        if ! [ -d "$configDir" ]; then
          echo "Copy ${cfg.prusaConfig} to $configDir"
          mkdir -p "$(dirname "$configDir")"
          set -x
          ${pkgs.rsync}/bin/rsync -r \
            --mkpath \
            --chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r \
            ${cfg.prusaConfig}/* \
            $configDir
          set +x
        else
          echo "$configDir already exists"
        fi
      '';
    };
    services.gitwatch = {
      modeling3d = {
        enable = true;
        user = config.user.name;
        remote = "git@github.com:ein-shved/3D.git";
        path = "${config.user.home}/Projects/3D";
      };
    };
  };
}

