{ pkgs, ... }:
let
  ripgrepConfig = pkgs.writeText "ripgrep.conf" ''
    --type-add=cin:Config.in
    --type-add=cc:*.[chH], *.[chH].in, *.cats
  '';
  ripgrepConfigured = pkgs.ripgrep.overrideAttrs (
    final: prev: {
      pname = "ripgrep-configured";
      nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postInstall =
        (prev.postInstall or "")
        + ''
          wrapProgram $out/bin/rg --set-default RIPGREP_CONFIG_PATH ${ripgrepConfig}
        '';
    }
  );
in
{
  config = {
    environment.systemPackages = [
      ripgrepConfigured
    ];
  };
}
