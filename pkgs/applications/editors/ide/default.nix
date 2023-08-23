{ lib, ... }:
lib.mkOverlay (
  { python3Packages, libsForQt5, ... }:
  {
    ide = python3Packages.buildPythonApplication {
        pname = "ide";
        version = "0.1";
        propagatedBuildInputs = [ python3Packages.pyqt5 ];
        src = ./.;
        nativeBuildInputs = [ libsForQt5.wrapQtAppsHook ];
        dontWrapQtApps = true;
        preFixup = ''
          wrapQtApp "$out/bin/ide" --prefix PATH : $out/bin/ide
        '';
        postInstall = ''
          mv $out/bin/ide.py $out/bin/ide
        '';
      };
  }
)
