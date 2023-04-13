let
  rev="d42a07373a2aec93d949818735a0d5ce6a849949";
  hasp-flake = builtins.getFlake "github:ein-shved/SentinelHasp.nix/${rev}";
  module = hasp-flake.packages.x86_64-linux.module;
in
module
