{ lib, ... }:
lib.mkOverlay (
  { kitty, fetchFromGitHub, ... }:
  {
    kitty = kitty.overrideAttrs (
      final: prev: {
        src = fetchFromGitHub {
          owner = "ein-shved";
          repo = "kitty";
          rev = "v${final.version}-patched";
          hash = "sha256-8tTh2jN4HA7HwUYddkDUCGKt0b72tayvFAjy+daWilM=";
        };
      }
    );
  }
)
