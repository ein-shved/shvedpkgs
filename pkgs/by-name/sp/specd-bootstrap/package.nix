{
  callPackage,
  lib,
  makeWrapper,
  rustPlatform,
  specd,
  specd-bootstrap-sdd-schema,
  specd-bootstrap-agent-kilocode,
  specd-bootstrap-agent-opencode,
  specd-bootstrap-agent-codex,
  specd-bootstrap-agent-packages ? [
    specd-bootstrap-agent-kilocode
    specd-bootstrap-agent-opencode
    specd-bootstrap-agent-codex
  ],
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "specd-bootstrap";
  version = "0.1.0";

  src = ./src;

  cargoLock.lockFile = ./src/Cargo.lock;

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram "$out/bin/specd-bootstrap" \
      --prefix PATH : ${lib.makeBinPath [ specd ]} \
      --set-default SPECD_BOOTSTRAP_SCHEMA_ROOT ${specd-bootstrap-sdd-schema}/share/specd-bootstrap/schemas/sdd \
      --set-default SPECD_BOOTSTRAP_AGENT_MANIFESTS '${lib.concatMapStringsSep ";" (agent: "${agent}/manifest.yaml") specd-bootstrap-agent-packages}'
  '';

  passthru.tests.vm = callPackage ../../../../tests/pkgs/specd-bootstrap.nix {
    specd-bootstrap = finalAttrs.finalPackage;
  };

  meta = {
    description = "Bootstrap target projects with this repository's SpecD SDD schema and agent skills";
    license = lib.licenses.mit;
    mainProgram = "specd-bootstrap";
  };
})
