{ stdenv,  lib, pkgs, substituteAll, sshfs-fuse,
  defaultserver ? null, defaultuser ? null }:
let
    srv = if defaultserver == null then "$HOSTNAME.avp.ru" else defaultserver;
    usr = if defaultuser == null then "$USER" else defaultuser;
in stdenv.mkDerivation {
    name = "klfs";
    version = "0.0.1";
    buildInputs = [ ];

    buildCommand = ''
        install -Dm755 $script $out/bin/klfs
    '';

    script = substituteAll {
        src = ./klfs.sh;
        isExecutable = true;
        inherit (stdenv) shell;
        sshfs = "${sshfs-fuse}/bin/sshfs";
        defaultserver = srv;
        defaultuser = usr;
    };

    meta = with stdenv.lib; {
        description = "Script to mount remote kl working folder";
    };
}

