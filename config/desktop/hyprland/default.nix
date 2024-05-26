{ config, pkgs, ... }:
let
  user = config.user.name;
in
{
  # Enable hyprland both from nixos and from home-manager. First will enable
  # required system options. The second - will enable configuration.
  programs.hyprland.enable = true;
  home-manager.users.${user} = {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      package = pkgs.hyprland;
      settings = {
      };
    };
  };
}

