{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.jellyfin = lib.mkIf config.hardware.isNas {
    enable = true;
    openFirewall = true;
    user = config.user.name;
  };
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];
}
