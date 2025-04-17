{ pkgs, config, ... }:
{
  home.programs =
    let
      inherit (pkgs) kitty;
      kitty-installation-dir = "${kitty}/lib/kitty";
    in
    {
      bash = {
        enable = true;
        bashrcExtra = ''
          if [ -z "$KITTY_INSTALLATION_DIR" ]; then
              export KITTY_INSTALLATION_DIR="${kitty-installation-dir}"
          fi
        '';
      };
      kitty = {
        # Enable kitty independently on graphic requirements, because we need
        # for kitten on remote machines.
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
          listen_on = ''unix:''${XDG_RUNTIME_DIR}/kitty-{kitty_pid}'';

          notify_on_cmd_finish = "unfocused 10.0";
        };
      };
    };
}
