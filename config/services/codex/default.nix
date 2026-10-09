{ config, lib, ... }:
{
  config = lib.mkIf config.hardware.development {
    services.codex = {
      enable = true;
      remoteControl.enable = true;
      user = config.user.name;
      home = config.user.home;
    };
  };
}
