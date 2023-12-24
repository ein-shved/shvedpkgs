{ config, ... }:
{
  services.gitwatch = {
    modeling3d = {
      enable = true;
      user = config.user.name;
      remote = "git@github.com:ein-shved/3D.git";
      path = "${config.user.home}/Projects/3D";
    };
  };
}
