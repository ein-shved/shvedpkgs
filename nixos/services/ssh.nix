{ config, pkgs, lib, ... }:
{
  config = {
    services = {
      openssh = {
        enable = true;
      };
    };
    local = {
      extras = (pkgs.mkLocalExtra "programs" {
        ssh = {
          enable = true;
          controlMaster = "yes";
          controlPath = "~/.ssh/control/master-%r@%n:%p";
          controlPersist = "30m";
          serverAliveInterval = 10;
        };
      });
      activations = {
        createSshControls = ''
          mkdir ~/.ssh/control -p;
        '';
      };
    };
  };
}
