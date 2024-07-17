{ config, pkgs, lib, ... }:
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
    ./waybar
  ];

  options.programs.hyprland = with lib; with types; {
    monitors = mkOption {
      description = ''
        The per-monitor configuration for hyprland, hyprpaper and hyprlock.
        The 'default' field will be applyied as default.
        You can use 'desc:My Monitor' format as monitor names.
        See details at manuals of
        [hyprland](https://wiki.hyprland.org/Configuring/Monitors/),
        [hyprpaper](https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper/) and
        [hyprlock](https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/)
      '';
      type = attrsOf (submodule {
        options = {
          resolution = mkOption {
            description = "Resolution for monitor";
            default = "preferred";
            type = str;
          };
          position = mkOption {
            description = "The position of monitor";
            default = "auto";
            type = str;
          };
          scale = mkOption {
            description = "Monitor scale";
            default = "1";
            type = str;
          };
          wallpaper = mkOption {
            description = "Wallpaper for monitor";
            default = null;
            type = nullOr path;
          };
        };
      });
      default = { };
    };
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
    home-manager.users.${user}.xdg.configFile =
      lib.concatMapAttrs
        (name: value:
          let
            hyprPart = str: lib.optionalString value.hypr str;
            name' = "${hyprPart "hypr/"}${name}${hyprPart ".conf"}";
          in
          {
            "${name'}" = { inherit (value) text onChange; };
          })
        cfg.hyprconfig;
  };
}

