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

  wallpaperMonitors = lib.filterAttrs (
    name: value: value ? wallpaper && value.wallpaper != null
  ) config.hardware.aliasedMonitors;
in
{
  options.hardware = {
    singleOutput.enable = mkEnableOption "this setup is used with single output";
    monitors = mkOption {
      description = ''
        The per-monitor configuration for display manager, desktop manager, lock
        screens and etc. The 'default' field will be applyied as default.
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
          isDefault = mkEnableOption "treating this monitor as default";
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
    wallpaperMonitors = mkOption {
      description = "Helper option with resolved monitors with wallpapers configured";
      type = anything;
      readOnly = true;
      internal = true;
      default = wallpaperMonitors;
    };
  };
}
