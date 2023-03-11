{ pkgs, ... }:
{
  nixpkgs.overlays = [ (self: super: {
    cntlm-gss = super.callPackage tools/networking/cntlm-gss {};
    # TODO (Shvedov) remove after 23.04
    ansi = super.callPackage development/tools/ansi {};
  }) ];
}
