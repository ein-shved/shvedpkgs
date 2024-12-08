{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) fetchFromGitHub freecad;
  inherit (lib) mkIf;
  cfg = config.environment;

  open-theme = fetchFromGitHub {
    owner = "obelisk79";
    repo = "OpenTheme";
    rev = "80399168ab27c660a9a14812b67492f412f3148f";
    hash = "sha256-NgrBvP+wRNED3JI8zG9JMT//xfZfivQC8yy4m2GsujM=";
  };

  freecad-customized = freecad.customize {
    modules = [
      open-theme
    ];
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
    ];
    userCfg = ./user.cfg;
  };
in
{
  config.environment = mkIf cfg.printing3d.enable {
    systemPackages = [ freecad-customized ];
  };
}
