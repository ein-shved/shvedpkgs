{ lib, ... }:
{
  config = {
    services = {
      openssh = {
        enable = true;
        settings.X11Forwarding = true;
      };
    };
    programs.ssh.startAgent = true;
    home = {
      extras = (
        lib.mkHmExtra "programs" {
          ssh = {
            enable = true;
            enableDefaultConfig = false;
            matchBlocks."*" = {
              addKeysToAgent = "no";
              compression = false;
              controlMaster = "no";
              controlPath = "~/.ssh/master-%r@%n:%p";
              controlPersist = "no";
              forwardAgent = false;
              hashKnownHosts = false;
              serverAliveCountMax = 3;
              serverAliveInterval = 10;
              userKnownHostsFile = "~/.ssh/known_hosts";
            };
          };
        }
      );
    };
  };
}
