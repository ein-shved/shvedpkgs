{ pkgs, ... }:
{
  nixpkgs.overlays = [ (self: super: {
    cntlm-gss = super.callPackage tools/networking/cntlm-gss {};
    neovide = super.callPackage applications/editors/neovim/neovide {
      neovide' = super.neovide;
    };
  }) ];
}
