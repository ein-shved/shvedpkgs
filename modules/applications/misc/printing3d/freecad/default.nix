{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) fetchFromGitHub freecad-wayland;
  inherit (lib) mkIf;
  cfg = config.environment;
  mcpEnabled = config.services.codex.enable && cfg.printing3d.enable;

  open-theme = fetchFromGitHub {
    owner = "obelisk79";
    repo = "OpenTheme";
    rev = "80399168ab27c660a9a14812b67492f412f3148f";
    hash = "sha256-NgrBvP+wRNED3JI8zG9JMT//xfZfivQC8yy4m2GsujM=";
  };

  freecad-customized = freecad-wayland.customize {
    modules = [
      open-theme
    ]
    ++ lib.optional mcpEnabled pkgs.freecad-mcp.addon;
    pythons = [
      (
        ps: with ps; [
          requests
          pyjwt
          tzlocal
        ]
      )
    ];
    makeWrapperFlags = [
      "--set-default"
      "QT_FONT_DPI"
      "80"
      "--set-default"
      "QT_QPA_PLATFORM"
      "xcb"
    ];
    userCfg = ./user.cfg;
  };
in
{
  config.environment = mkIf cfg.printing3d.enable {
    systemPackages = [ freecad-customized ] ++ lib.optional mcpEnabled pkgs.freecad-mcp;
  };
}
