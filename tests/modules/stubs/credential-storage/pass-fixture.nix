{
  runCommand,
  gnupg,
  pass,
  git,
  gawk,
}:
let
  directory = "/var/lib/pass-fixture";
in
{
  # The package interface is real; its disposable key is generated in the VM.
  key = runCommand "pass-fixture-key" { } ''
    mkdir -p "$out"
    ln -s ${directory}/gpg.id "$out/gpg.id"
  '';
  repository = "file://${directory}/password-store.git";
  node = {
    systemd.services.pass-fixture = {
      requiredBy = [ "home-manager-fixture.service" ];
      before = [ "home-manager-fixture.service" ];
      unitConfig.ConditionPathExists = "!${directory}/ready";
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "pass-fixture";
        UMask = "0077";
      };
      path = [
        gnupg
        pass
        git
        gawk
      ];
      script = ''
        # Root only produces fixtures in its separate GPG home. The primary
        # user's first GPG command must come from the module's private setup.
        export GNUPGHOME=${directory}/gnupg
        export PASSWORD_STORE_DIR=${directory}/password-store
        mkdir -m 0700 -p "$GNUPGHOME"
        trap 'gpgconf --kill all' EXIT
        gpg --batch --pinentry-mode loopback --passphrase fixture-passphrase \
          --quick-generate-key 'Fixture <fixture@example.invalid>' rsa2048 encr 0
        gpg --batch --pinentry-mode loopback --passphrase fixture-passphrase \
          --export-secret-keys fixture@example.invalid > ${directory}/gpg.id
        gpg --batch --with-colons --with-keygrip \
          --list-secret-keys fixture@example.invalid |
          awk -F: '$1 == "grp" { print $10 }' > ${directory}/keygrips

        git init --initial-branch=main "$PASSWORD_STORE_DIR"
        git -C "$PASSWORD_STORE_DIR" config user.name Fixture
        git -C "$PASSWORD_STORE_DIR" config user.email fixture@example.invalid
        pass init fixture@example.invalid
        printf '%s\n' fixture-secret | pass insert --multiline fixture
        git clone --bare "$PASSWORD_STORE_DIR" ${directory}/password-store.git
        chmod 0755 ${directory}
        chmod 0644 ${directory}/gpg.id
        chmod -R a+rX ${directory}/password-store.git
        touch ${directory}/ready
      '';
    };
  };
}
