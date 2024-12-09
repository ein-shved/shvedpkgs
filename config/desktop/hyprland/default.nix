{
  config,
  lib,
  ...
}:
let
  user = config.user.name;
  cfg = config.programs.hyprland;
in
{
  imports = [
    ./anyrun.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./kitty.nix
    ./waybar
  ];

  options.programs.hyprland =
    with lib;
    with types;
    {
      hyprconfig = mkOption {
        description = ''
          Configuration files for hypr environment utility. The file will be
          placed to XDG config dir at `hypr/''${name}.conf`.
        '';
        type = attrsOf (submodule {
          options = {
            text = mkOption {
              description = "Text of config";
              type = lines;
            };
            onChange = mkOption {
              description = "Script to run upon file changed";
              default = "";
              type = lines;
            };
            hypr = mkOption {
              description = "Whenether this is hypr environment config";
              type = bool;
              default = true;
            };
          };
        });
        default = { };
      };
    };

  config = {
    home-manager.users.${user}.xdg.configFile = lib.concatMapAttrs (
      name: value:
      let
        hyprPart = str: lib.optionalString value.hypr str;
        name' = "${hyprPart "hypr/"}${name}${hyprPart ".conf"}";
      in
      {
        "${name'}" = { inherit (value) text onChange; };
      }
    ) cfg.hyprconfig;
  };
}
