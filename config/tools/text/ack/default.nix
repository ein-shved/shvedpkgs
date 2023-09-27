{ lib, config, pkgs, ... }:
{
  config = {
    environment.systemPackages = with pkgs; [
      ack
    ];
    home.home.file = {
      ".ackrc".text = ''
        --type-set=nix:ext:nix
        --type-set=cin:is:Config.in
      '';
    };
  };
}

