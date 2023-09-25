{ config, lib, ... }:
let
  cfg = config.nixpkgs.config;
in
{
  config = {
    nixpkgs.config.permittedInsecurePackages =
      [
        # TODO remove this after getting rid of outdated packages.
        # Known packages are:
        # pcsc-safenet
        # pcsc-safenet-legacy
        # pcsclite
        "openssl-1.1.*"
        "python-2.7.*"
      ];

    nixpkgs.config.allowInsecurePredicate = with builtins; pkg:
      let
        fullName = concatStringsSep "-"
          [ (lib.getName pkg) (lib.getVersion pkg) ];
        matches = map (re: match re fullName)
          cfg.permittedInsecurePackages;
      in
      foldl' (res: elem: res || (elem != null)) false matches;
  };
}
