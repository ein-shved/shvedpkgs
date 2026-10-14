{
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "specd-bootstrap-sdd-schema";
  version = "0.1.0";

  src = ../../../../schemas/sdd;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/specd-bootstrap/schemas/sdd"
    cp -R . "$out/share/specd-bootstrap/schemas/sdd/"

    runHook postInstall
  '';

  meta = {
    description = "Reusable SpecD SDD schema assets for specd-bootstrap";
    license = lib.licenses.mit;
  };
}
