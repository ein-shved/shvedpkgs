{
  lib,
  rustPlatform,
  clippy,
  makeWrapper,
  installShellFiles,
  nixos-rebuild,
  catalog ? null,
}:

rustPlatform.buildRustPackage {
  pname = "nixos-cli";
  version = "0.1.0";

  src = lib.cleanSource ./src;
  cargoLock.lockFile = ./src/Cargo.lock;

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];
  postInstall = ''
    wrapProgram $out/bin/nixos \
      --prefix PATH : ${lib.makeBinPath [ nixos-rebuild ]} \
      ${lib.optionalString (
        catalog != null
      ) "--set NIXOS_CLI_CONFIG ${lib.escapeShellArg (toString catalog)}"}

    installShellCompletion --cmd nixos \
      --bash --name nixos ${./completions/nixos.bash} \
      --zsh ${./completions/_nixos}
    substituteInPlace \
      $out/share/bash-completion/completions/nixos \
      $out/share/zsh/site-functions/_nixos \
      --replace-fail '@nixos@' "$out/bin/nixos" \
      --replace-fail '@upstream@' '${nixos-rebuild}'
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
