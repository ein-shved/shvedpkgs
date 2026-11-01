{
  config,
  lib,
  pkgs,
  extensions,
  ...
}:
let
  cfg = config.programs.nixos-cli;
  targets = lib.filterAttrs (
    _: host: host.config.programs.nixos-cli.remoteAddress != null
  ) extensions.nixosConfigurations;
  settings =
    host:
    {
      target_host = host.config.programs.nixos-cli.remoteAddress;
      use_sudo = host.config.programs.nixos-cli.useSudo;
      ask_sudo_password = host.config.programs.nixos-cli.askSudoPassword;
    }
    // lib.optionalAttrs (host.options.user.name.isDefined or false) {
      user = host.config.user.name;
    };
  canonical = lib.mapAttrs (_: settings) targets;
  aliases = lib.listToAttrs (
    lib.concatLists (
      lib.mapAttrsToList (
        name: host:
        lib.optional (host.config.networking.hostName != name) {
          name = host.config.networking.hostName;
          value = settings host;
        }
      ) targets
    )
  );
  catalog = pkgs.writeText "nixos-cli-catalog.json" (builtins.toJSON (aliases // canonical));
in
{
  options.programs.nixos-cli = {
    enable = lib.mkEnableOption "the NixOS management CLI";
    remoteAddress = lib.mkOption {
      type = lib.types.nullOr (lib.types.strMatching ".+");
      default = null;
      description = "Address publishing this host as a remote nixos target.";
    };
    useSudo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether updating this host requires sudo.";
    };
    askSudoPassword = lib.mkOption {
      type = lib.types.bool;
      default = config.security.sudo.wheelNeedsPassword;
      defaultText = lib.literalExpression "config.security.sudo.wheelNeedsPassword";
      description = "Whether updating this host prompts for a sudo password.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ (pkgs.nixos-cli.override { inherit catalog; }) ];
  };
}
