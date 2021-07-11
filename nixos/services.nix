{ config, pkgs, ... }:
{
    config = {
        services.openssh = {
            enable = true;
        };
    };
}
