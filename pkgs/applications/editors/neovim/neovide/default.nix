{ lib, ... }:
lib.mkOverlay (
  { rustPlatform, fetchFromGitHub, path, callPackage, ... } :
  let
    rustPlatform' = { src, cargo }: rustPlatform // {
      buildRustPackage.override = overs: args:
        rustPlatform.buildRustPackage.override overs (args // {
          inherit src;
          cargoLock = args.cargoLock // {
            lockFile = cargo;
            outputHashes = { };
          };
        });
    };
    neovide' = args:
      callPackage "${path}/pkgs/applications/editors/neovim/neovide" {
        rustPlatform = rustPlatform' args;
    };

    neovide-0_11 = neovide' {
      src = fetchFromGitHub {
        owner = "neovide";
        repo = "neovide";
        rev = "0.11.0";
        sha256 = "OIAGqr34QcpYVUTcW+aPoGeBez/VuT6sSFC5JQaodOI=";
      };
      cargo = ./Cargo-0_11.lock;
    };

    neovide-0_10_fredizzimo = neovide' {
      src = fetchFromGitHub {
        owner = "fredizzimo";
        repo = "neovide";
        rev = "fsundvik/fix-keyboard-api";
        sha256 = "7FA9xmGZMddF8OI5z/pO2VeSlyeKFpBdb8HKXaUTkwU=";
      };
      cargo = ./Cargo-0_10_fredizzimo.lock;
    };
  in
    {
      # TODO(Shvedov) I need for neovide with winit update
      # https://github.com/neovide/neovide/pull/1789. But it was introduced
      # within 0.11 version, which failed to build with current nixos-23.05. So
      # I took a developper branch for now.
      neovide = neovide-0_10_fredizzimo;
    }
  )

