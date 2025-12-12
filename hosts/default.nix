let
  userconfig = {
    user = {
      name = "shved";
      humanName = "Yury Shvedov";
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
  "ShvedWsl"
]
