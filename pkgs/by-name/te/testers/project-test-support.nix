{ lib, extensions }:
{ config, ... }:
{
  # apply also restores defaults after extendNixOS replaces specialArgs.
  options.node.specialArgs = lib.mkOption {
    apply = args: {
      inherit lib extensions;
      inherit (extensions) flake-inputs;
      projectTestConfig = config;
    } // args;
  };
  config.node.pkgsReadOnly = lib.mkDefault false;
  config.extraBaseNodeModules = {
    imports = extensions.modules;
    _module.args.pkgsUnstable = extensions.pkgsUnstable;
  };
}
