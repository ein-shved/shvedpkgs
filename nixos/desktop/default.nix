{ config, pkgs, lib, ... }:
with pkgs;
let
    mozilla_merge_nss = callPackage ./mozilla_merge_nss {};
    xfce_conf = callPackage ./xfce4 {};
in {
    imports = [
        <home-manager/nixos>
    ];
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
        layout = "us,ru";
    };
    fonts.fonts = [
        jetbrains-mono
    ];
    time.timeZone = "Europe/Moscow";
    qt5 = {
        enable = true;
        platformTheme = "gtk2";
        style = "gtk2";
    };
    hardware.pulseaudio.enable = true;
    environment.systemPackages = with xfce; [
        xfce4-battery-plugin
        xfce4-clipman-plugin
        xfce4-pulseaudio-plugin
        xfce4-xkb-plugin
    ];
    programs.nm-applet.enable = true;
    home-manager = {
        useGlobalPkgs = true;
        users.shved = { pkgs, ...  }: {
            home.activation = let
                hm = callPackage <home-manager/modules/lib> { };
                dag = hm.dag;
            in {
                mergeMzNssDb = dag.entryAfter["writeBoundary"] ''
                    ${mozilla_merge_nss}/bin/mozilla_merge_nss
                '';
                globalTrustedCerts = dag.entryAfter["mergeMzNssDb"] ''
                    ln -sf ${nss_latest}/lib64/libnssckbi.so $HOME/.pki/nssdb
                '';
#                xfceConfig = dag.entryAfter["writeBoundary"] ''
#                    XFCONFPATH=$HOME/.config/xfce4
#                    mkdir -p "$XFCONFPATH"
#                    cp -r ${xfce_conf}/xfconf "$XFCONFPATH/"
#
#                '';
            };
        };
    };
}
