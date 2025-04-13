{ config, lib, ... }:
let
  port = 2121;
  pasv_port = 21211;
in
{
  services.vsftpd = lib.mkIf config.hardware.isNas {
    enable = true;
    localUsers = true;
    localRoot = config.services.mediaStore;
    writeEnable = true;
    extraConfig = ''
      listen_port=${builtins.toString port}
      max_clients=1
      pasv_min_port=${builtins.toString pasv_port}
      pasv_max_port=${builtins.toString pasv_port}
    '';
  };
  networking.firewall = lib.mkIf config.hardware.isNas {
    allowedTCPPorts = [
      port
      pasv_port
    ];
  };
}
