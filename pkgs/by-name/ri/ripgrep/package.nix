{
  pkgsOrigin,
  writeTextFile,
  makeWrapper,

  config ? null,

  ...
}@args:
if config == null then
  pkgsOrigin.ripgrep
else
  let
    origArgs = builtins.removeAttrs args [
      "pkgsOrigin"
      "writeTextFile"
      "makeWrapper"
      "config"
    ];
    ripgrepPkg' = pkgsOrigin.ripgrep.override origArgs;
    configFile = writeTextFile {
      name = "ripgrep.conf";
      text = config;
    };
  in
  ripgrepPkg'.overrideAttrs (
    final: prev: {
      nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [ makeWrapper ];
      postInstall =
        (prev.postInstall or "")
        + ''
          wrapProgram $out/bin/rg --set-default RIPGREP_CONFIG_PATH ${configFile}
        '';
    }
  )
