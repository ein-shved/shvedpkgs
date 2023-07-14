{ neovide', rustPlatform, fetchFromGitHub, pkgs } :
let
  rustPlatform' = rustPlatform // {
    buildRustPackage.override = overs: args:
      rustPlatform.buildRustPackage.override overs (args // {
        src = fetchFromGitHub {
          owner = "fredizzimo";
          repo = "neovide";
          rev = "fsundvik/fix-keyboard-api";
          sha256 = "rfRlI0ZiF009XmA0mPGqiHBuiKa3ENHtTdiDCG0YO2o=";
        };
        cargoLock = args.cargoLock // {
          lockFile = ./Cargo.lock;
          outputHashes = { };
        };
      });
  };
in
  pkgs.callPackage <nixpkgs/pkgs/applications/editors/neovim/neovide> {
    rustPlatform = rustPlatform';
  }
