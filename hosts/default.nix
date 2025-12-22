let
  userconfig = {lib, ...}: {
    user = {
      name = lib.mkDefault "shved";
      humanName = lib.mkDefault "Yury Shvedov";
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
in
mkHosts [
  "Shvedov-NB"
  "Shvedov"
  "ShvedLaptop"
  "ShvedGaming"
  "ShvedMedia"
  "y.shvedov@corp.1440.space"
]
