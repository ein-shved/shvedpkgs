{
  # Run with
  # nixos-rebuild build-vm --flake .#testA && \
  # QEMU_NET_OPTS="hostfwd=tcp::2221-:22" ./result/bin/run-nixos-vm
  testA = {
    configs = [
      ./vm/configuration.nix
      {
        user = {
          name = "alice";
          humanName = "Alice Cooper";
          password = "alice";
        };
        home.enable = true;
        hardware.isGraphic = true;
        hardware.isDevelopment = true;
        kl.remote.enable = true;
      }
    ];
  };
  testB = {
    configs = [
      ./vm/configuration.nix
      {
        user = {
          name = "bob";
          humanName = "Bob";
          password = "bob";
        };
        home.enable = true;
        hardware.isGraphic = true;
        hardware.isDevelopment = true;
        environment.printing3d.enable = true;
        kl.domain.enable = true;
      }
    ];
  };
  testNas = {
    configs = [
      ./vm/configuration.nix
      {
        user = {
          name = "nas";
          humanName = "Nas";
          password = "nas";
        };
        home.enable = true;
        hardware.isNas = true;
      }
    ];
  };
  testVps = {
    configs = [
      ./vm/configuration.nix
      {
        user = {
          name = "vps";
          humanName = "Vps";
          password = "vps";
        };
        home.enable = true;
        hardware.isVps = true;
        services.gerrit.serverId = "24247d56-4f56-473f-99f0-6680a185b369";
      }
    ];
  };
}
