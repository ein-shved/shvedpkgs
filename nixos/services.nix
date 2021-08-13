{ config, pkgs, ... }:
{
    config = {
        services.openssh = {
            enable = true;
        };
        networking.networkmanager.enable = true;
    };
}
