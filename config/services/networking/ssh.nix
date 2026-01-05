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
      extras = (lib.mkHmExtra "programs" {
        ssh = {
          enable = true;
          serverAliveInterval = 10;
        };
      });
    };
  };
}
