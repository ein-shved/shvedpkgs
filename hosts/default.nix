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
  tests = import ./tests;
in
tests
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
