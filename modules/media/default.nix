{ config, lib, ... }:
{
  options = {
    services.mediaStore = lib.mkOption {
      description = ''
        Path to media storage, where download media to and share from.
      '';
      type = lib.types.path;
      default = "${config.user.home}/Downloads";
    };
  };
}
