{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    mkEnableOption
    concatMapAttrs
    unique
    map
    foldl'
    ;
  inherit (lib.types)
    submodule
    attrsOf
    str
    nullOr
    path
    listOf
    anything
    bool
    ;

  cfg = config.hardware.monitors;

  aliasedMonitors = concatMapAttrs (
    name: m:
    let
      # Aliases of monitor (with original name)
      aliases = unique (m.aliases ++ [ name ]);
      # All sets of aliases for monitor
      mkMon = alias: { "${alias}" = m; };
      aliasedList = map mkMon aliases;
    in
    # Fold list to one set
    foldl' (res: v: res // v) { } aliasedList
  ) cfg;

in
{
  options.hardware = {
    singleOutput.enable = mkEnableOption "this setup is used with single output";
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
          enable = mkOption {
            description = "Whenether to enable monitor";
            default = true;
            type = bool;
          };
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
          aliases = mkOption {
            description = "Aliases names for monitor";
            default = [ ];
            type = listOf str;
          };
        };
      });
      default = { };
    };
    aliasedMonitors = mkOption {
      description = "Helper option with resolved monitors aliases";
      type = anything;
      readOnly = true;
      internal = true;
      default = aliasedMonitors;
    };
  };
}
