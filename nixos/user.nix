{ config, pkgs, ... }:
{
    users.users.shved = {
        createHome = true;
        isNormalUser = true;
        home = "/home/shved";
        description = "Yury Shvedov";
        extraGroups = [ "wheel" ];
    };
}
