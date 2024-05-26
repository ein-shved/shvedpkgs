{ config, lib, pkgs, modulesPath, ... }: {
# TODO(Shvedov): Remove affter https://github.com/NixOS/nixpkgs/issues/59219
# resolution
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];
  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      graphics = true;
    };
  };

  virtualisation.qemu.options = [
    "-device virtio-vga-gl"
    "-display sdl,gl=on,show-cursor=off"
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  environment.systemPackages = with pkgs; [
    htop
  ];

  system.stateVersion = "23.05";
}
