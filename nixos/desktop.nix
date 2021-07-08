{ config, pkgs, ... }:
{
    nixpkgs.config.pulseaudio = true;
    services.xserver = {
        enable = true;
        desktopManager.xfce = {
            enable = true;
        };
        displayManager =  {
            lightdm = {
                enable = true;
            };
            defaultSession = "xfce";
        };
        videoDrivers = [ "modesetting" ];
        useGlamor = true;
    };
    qt5 = {
        enable = true;
        platformTheme = "gtk2";
        style = "gtk2";
    };
}
