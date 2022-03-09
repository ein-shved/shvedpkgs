{ pkgs, config, lib, ... }:
let
  optionalImport = name:
    let
      pname = "/" + name;
      pnamex = pname + ".nix";
    in
      if builtins.pathExists (./. + pname + "/default.nix")
        then [ (./. + pname) ]
      else if builtins.pathExists (./. + pnamex)
        then [ (./. + pnamex) ]
      else
        [];
  optionalImports = imports: lib.flatten (map optionalImport imports);
in {
  imports = [
    ./nixos
  ] ++ (optionalImports [
    "secrets"
    "nda"
  ]);

  config = {
    local = {
      user = {
        login = "shved";
        name = "Yury Shvedov";
      };
      kl = {
        #remote.enable = true;
        domain = {
          #enable = false;
          #host = "nda";
          #dockerName = "nda";
        };
      };
      gnupass = {
        #enable = true;
        #giturl = "secret";
        #gpgid = "secret";
      };
      #threed.enable = false;
      #optimus.enable = true;
    };
    programs = {
      firefox.enable = false;
      chromium = {
        enable = true;
      };
    };
    services = {
      spotify.daemon = false; # Spotifyd is a piece of crap
    };
  };
}

