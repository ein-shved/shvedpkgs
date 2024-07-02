{ config, pkgs, hyprland-flake, hyprland-plugins, ... }:
let
  user = config.user.name;
in
{
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
  # Enable hyprland both from nixos and from home-manager. First will enable
  # required system options. The second - will enable configuration.
  programs.hyprland = {
    enable = true;
    package = hyprland-flake.packages.${pkgs.system}.hyprland;
  };

  home-manager.users.${user} = {
    imports = [ hyprland-flake.homeManagerModules.default ];
    wayland.windowManager.hyprland = {
      # enable = true;
      systemd.enable = true;
      extraConfig =  builtins.readFile ./hyprland.conf;
      plugins = [
        hyprland-plugins.packages.${pkgs.system}.hyprbars
      ];
      # settings = {
      #   "$terminal" = "kitty";
      #   decoration = {
      #     shadow_offset = "0 5";
      #     "col.shadow" = "rgba(00000099)";
      #   };
      #
      #   "$mod" = "SUPER";
      #
      #   bindm = [
      #     # mouse movements
      #     "$mod, mouse:272, movewindow"
      #     "$mod, mouse:273, resizewindow"
      #     "$mod ALT, mouse:272, resizewindow"
      #   ];
      #
      #   bind = [
      #     "$mod, Q, exec, $terminal"
      #   ];
      # };
    };
  };
  environment.systemPackages = with pkgs; [
    kitty
  ];
}

