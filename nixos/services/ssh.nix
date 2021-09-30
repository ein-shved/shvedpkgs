{ config, pkgs, lib, ... }:
{
  config = {
    services = {
      openssh = {
        enable = true;
      };
    };
    local.extras = (pkgs.mkLocalExtra "programs" {
      ssh = {
        enable = true;
        controlMaster = "yes";
        controlPersist = "30m";
        serverAliveInterval = 10;
      };
    });
  };
}
