{ lib, config, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
  cfg = config.local.optimus.nvidia;
in
{
  options.local.optimus = {
    nvidia = {
      enable = lib.mkEnableOption ''
        Does this machine uses nvidia optimus scheme
      '';
      intelBusId = lib.mkOption {
        default = "PCI:0:2:0";
        description = "See hardware.nvidia.prime.intelBusId";
      };
      nvidiaBusId = lib.mkOption {
        default = "PCI:1:0:0";
        description = "See hardware.nvidia.prime.nvidiaBusId";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [ nvidia-offload ];
    };

    services.xserver = {
      videoDrivers = [ "nvidia" ];
    };
    hardware.nvidia.prime = {
      offload.enable = true;
      intelBusId = cfg.intelBusId;
      nvidiaBusId = cfg.nvidiaBusId;
    };
  };
}

