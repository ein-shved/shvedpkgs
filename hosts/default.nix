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
  Shvedov = {
    modules = [
      ./Shvedov/configuration.nix
      userconfig
      {
        kl.domain.enable = true;
      }
    ];
  };
  ShvedLaptop = {
    modules = [
      ./ShvedLaptop/configuration.nix
      userconfig
    ];
  };
  ShvedGaming = {
    modules = [
      ./ShvedGaming/configuration.nix
      userconfig
    ];
  };
}
