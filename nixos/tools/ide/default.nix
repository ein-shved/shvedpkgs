{ pkgs, ... }:
with pkgs.python3Packages;
with pkgs.libsForQt5;
buildPythonApplication {
    pname = "ide";
    version = "0.1";
    propagatedBuildInputs = [ pyqt5 ];
    src = ./.;
    nativeBuildInputs = [ wrapQtAppsHook ];
    dontWrapQtApps = true;
    preFixup = ''
        wrapQtApp "$out/bin/ide" --prefix PATH : $out/bin/ide
    '';
    postInstall = ''
        mv $out/bin/ide.py $out/bin/ide
    '';
}
