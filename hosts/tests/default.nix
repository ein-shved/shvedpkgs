{
  # Run with
  # nixos-rebuild build-vm --flake .#testA && \
  # QEMU_NET_OPTS="hostfwd=tcp::2221-:22" ./result/bin/run-nixos-vm
  testA = {
    modules = [
      ./vm/configuration.nix
      {
        user = {
          name = "alice";
          humanName = "Alice Cooper";
          password = "alice";
        };
        kl.remote.enable = true;
      }
    ];
  };
  testB = {
    modules = [
      ./vm/configuration.nix
      {
        user = {
          name = "bob";
          humanName = "Bob";
          password = "bob";
        };
        environment.printing3d.enable = true;
        kl.domain.enable = true;
      }
    ];
  };
  testNas = {
    modules = [
      ./vm/configuration.nix
      {
        user = {
          name = "nas";
          humanName = "Nas";
          password = "nas";
        };
        hardware.isNas = true;
      }
    ];
  };
  testVps = {
    modules = [
      ./vm/configuration.nix
      {
        user = {
          name = "vps";
          humanName = "Vps";
          password = "vps";
        };
        hardware.isVps = true;
        services.gerrit.serverId = "24247d56-4f56-473f-99f0-6680a185b369";
      }
    ];
  };
}
