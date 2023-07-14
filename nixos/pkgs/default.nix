{ pkgs, ... }:
{
  nixpkgs.overlays = [ (self: super: {
    cntlm-gss = super.callPackage tools/networking/cntlm-gss {};
  }) ];
}
