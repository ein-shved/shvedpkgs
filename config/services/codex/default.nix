{
  config,
  lib,
  pkgsUnstable,
  ...
}:
{
  services.codex = lib.mkIf config.hardware.isDevelopment {
    enable = true;
    remoteControl.enable = true;
    user = config.user.name;
    package = pkgsUnstable.codex;
  };
}
