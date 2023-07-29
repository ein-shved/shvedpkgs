{ lib, home-manager, ... }:
let
  withdraw = with lib.attrsets; let
    op = val: pkgs: filterAttrs
      (
        name: _v:
          if val then
            name == "imports"
          else
            name != "imports"
      )
      pkgs;
  in
  {
    pkgs = op false;
    imports = pkgs:
      let
        subset = (op true pkgs);
      in
      if subset ? imports then
        subset.imports
      else
        [ ];
  };

  processChild = pkgs: attrs: (withdraw.pkgs attrs) //
    (processImports pkgs (withdraw.imports attrs));

  processImports = pkgs: imports:
    builtins.foldl'
      (all: imp: all // (processChild pkgs
        (pkgs.callPackage imp { })
      ))
      { }
      imports;

  overlays = pkgs: processChild pkgs {
    imports = [
      ./applications
      ./tools
      ./data
    ];
  };
in
{
  nixpkgs.overlays = [
    (self: super:
      let
        pkgs = super.extend (_self: _super: {
          inherit home-manager lib;
        });
      in
      {
        inherit (overlays pkgs)
          cntlm-gss
          gcmnu
          gcmu
          gitupdate
          klcacerts
          ;
      }
    )
  ];
}
