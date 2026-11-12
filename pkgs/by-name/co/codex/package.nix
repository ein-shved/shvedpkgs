{ pkgsUnstable }:
pkgsUnstable.codex.overrideAttrs (previousAttrs: {
  # Backport the system libraries missing from the pinned nixpkgs recipe.
  buildInputs = previousAttrs.buildInputs ++ [
    pkgsUnstable.aws-lc
    pkgsUnstable.oniguruma
    pkgsUnstable.sqlite
    pkgsUnstable.zstd
  ];
})
