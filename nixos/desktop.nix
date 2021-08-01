{ config, pkgs, lib, ... }:
with pkgs;
let
    mozilla_merge_nss = callPackage ./mozilla_merge_nss { };
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
    };
    qt5 = {
        enable = true;
        platformTheme = "gtk2";
        style = "gtk2";
    };
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
            };
        };
    };
}
