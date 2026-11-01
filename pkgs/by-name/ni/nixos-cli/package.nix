{
  lib,
  rustPlatform,
  clippy,
  makeWrapper,
  nixos-rebuild,
  catalog ? null,
}:

rustPlatform.buildRustPackage {
  pname = "nixos-cli";
  version = "0.1.0";

  src = lib.cleanSource ./src;
  cargoLock.lockFile = ./src/Cargo.lock;

  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/nixos \
      --prefix PATH : ${lib.makeBinPath [ nixos-rebuild ]} \
      ${lib.optionalString (
        catalog != null
      ) "--set NIXOS_CLI_CONFIG ${lib.escapeShellArg (toString catalog)}"}
  '';

  nativeCheckInputs = [ clippy ];

  preCheck = ''
    echo "Running cargo clippy"
    cargo clippy --offline --locked --all-targets -- -D warnings
  '';

  meta = {
    description = "Manage local and named NixOS rebuilds";
    mainProgram = "nixos";
    platforms = lib.platforms.unix;
  };
}
