{
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "specd-bootstrap-agent-opencode";
  version = "0.1.0";

  src = ./src;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 manifest.yaml "$out/manifest.yaml"
    mkdir -p "$out/skills"
    cp -R skills/. "$out/skills/"

    runHook postInstall
  '';

  meta = {
    description = "opencode SpecD skills for specd-bootstrap";
    license = lib.licenses.mit;
  };
}
