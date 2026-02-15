flake-inputs:
let
  paths = [
    ./modules.nix
    ./system.nix
  ];
in
flake-inputs.nixpkgs.lib.extend (
  final: prev: builtins.foldl' (l: p: l // import p final prev) { inherit flake-inputs; } paths
)
