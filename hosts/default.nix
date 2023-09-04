let
  userconfig = {
    user = {
      name = "shved";
      humanName = "Yury Shvedov";
    };
  };
in
{
  Shvedov-NB = {
    modules = [
      ./Shvedov-NB/configuration.nix
      userconfig
      {
        kl.remote.enable = true;
      }
    ];
  };
}
