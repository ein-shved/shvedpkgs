{ ... }:
{
  programs.hyprland.hyprconfig = {
    "kitty/kitty.conf" = {
      hypr = false;
      text = ''
        background_opacity            0.7

        scrollback_lines              200000
        scrollback_pager_history_size 1024

        tab_bar_min_tabs              1
        tab_bar_style                 powerline

        # Reset SHLVL. For example, with hdrop SHLVL starts from 2.
        env                           SHLVL=0
      '';
    };
  };
}

