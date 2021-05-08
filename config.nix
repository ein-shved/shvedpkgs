{ pkgs }:
let
   shvedsVim = pkgs.callPackage ./vim {};

in {
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; {
    shvedsPackages = pkgs.buildEnv {
      name = "shveds-packages";
      paths = [
        shvedsVim
      ];
    };
  };
}
