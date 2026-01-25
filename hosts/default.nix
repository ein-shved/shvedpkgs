let
  userconfig =
    { lib, ... }:
    {
      user = {
        name = lib.mkDefault "shved";
        humanName = lib.mkDefault "Yury Shvedov";
        mail = lib.mkDefault "mestofel13@gmail.com";
      };
    };
  mkHost = name: {
    "${name}" = {
      modules = [
        (./. + "/${name}/configuration.nix")
        userconfig
      ];
    };
  };
  mkHosts = names: builtins.foldl' (res: name: res // mkHost name) { } names;
  tests = import ./tests;
  boots = import ./boots;
in
tests
// boots
// {
  generic = {
    modules = [ { user.name = "NixOS"; } ];
  };
}
// mkHosts [
  "Shvedov-NB"
  "Shvedov"
  "ShvedLaptop"
  "ShvedGaming"
  "ShvedMedia"
]
