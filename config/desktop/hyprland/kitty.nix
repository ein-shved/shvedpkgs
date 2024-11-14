{ config, pkgs, ... }:
let
  user = config.user.name;
in
{
  home-manager.users.${user} =
    let
      inherit (pkgs) kitty;
      kitty-installation-dir = "${pkgs.kitty}/lib/kitty";
    in
    {
      programs.bash = {
        enable = true;
        bashrcExtra = ''
          if [ -z "$KITTY_INSTALLATION_DIR" ]; then
              export KITTY_INSTALLATION_DIR="${kitty-installation-dir}"
          fi
        '';
      };
      programs.kitty = {
        enable = true;
        package = kitty;
        shellIntegration = {
          mode = "enabled";
          enableBashIntegration = true;
        };
        settings = {
          background_opacity = "0.7";
          scrollback_lines = 200000;
          scrollback_pager_history_size = 1024;
          tab_bar_min_tabs = 1;
          tab_bar_style = "powerline";
          enabled_layouts = "horizontal";
          allow_remote_control = "yes";

          notify_on_cmd_finish = "unfocused 10.0";
        };
      };
    };
}

