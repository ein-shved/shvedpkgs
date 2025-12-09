{
  pkgsOrigin,
}:
pkgsOrigin.pass.overrideAttrs (
  final: prev: {
    patches = prev.patches or [ ] ++ [
      ./0001-Fix-bash-completion-for-extensions.patch
    ];
  }
)
