let
  user.name = "nixos";
in
{
  bootWork = {
    modules = [
      {
        inherit user;
        hardware.bluetooth.enable = true;
      }
    ];
  };
  bootGaming = {
    modules = [
      {
        inherit user;
        hardware.bluetooth.enable = true;
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia = {
          modesetting.enable = true;
          open = false;
          nvidiaSettings = true;
        };
        environment = {
          printing3d.enable = true;
          gaming.enable = true;
        };
      }
    ];
  };
  bootServer = {
    modules = [
      {
        inherit user;
        hardware.isVps = true;
        # hardware.isNas = true; # TODO
        services.gerrit.serverId = "24247d56-4f56-473f-99f0-6680a185b369";
      }
    ];
  };
}
