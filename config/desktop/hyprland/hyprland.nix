{ config, pkgs, lib, ... }:
let
  user = config.user.name;
  monitors = config.programs.hyprland.monitors;
in
{
  config = {
    # Enable hyprland both from nixos and from home-manager. First will enable
    # required system options. The second - will enable configuration.
    programs.hyprland = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      anyrun
      brightnessctl
      hdrop
      hypridle
      hyprland-per-window-layout
      hyprlock
      hyprpaper
      hyprshot
      kitty
      pavucontrol
      udiskie
      waybar
      wl-clipboard
    ];

    home-manager.users.${user} = {
      home.pointerCursor = {
        gtk.enable = true;
        # x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      gtk = {
        enable = true;

        theme = {
          package = pkgs.flat-remix-gtk;
          name = "Flat-Remix-GTK-Grey-Darkest";
        };

        iconTheme = {
          package = pkgs.gnome.adwaita-icon-theme;
          name = "Adwaita";
        };

        font = {
          name = "Sans";
          size = 11;
        };
      };
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        extraConfig =
          let
            monName = name: lib.optionalString (name != "default") name;
            mkMonitor = name: value:
              "monitor = ${monName name}, ${value.resolution}, ${value.position}, ${value.scale}";
            monitors' = lib.foldlAttrs
              (acc: name: value: acc + "\n${mkMonitor name value}") ""
              monitors;
          in
          ''
            exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME
            #
            # Based on basic auto-generated hyprland configuration
            #

            ${monitors'}

            # See https://wiki.hyprland.org/Configuring/Keywords/ for more
            exec-once = waybar
            exec-once = hypridle
            exec-once = hyprpaper
            exec-once = udiskie

            # Source a file (multi-file configs)
            # source = ~/.config/hypr/myColors.conf

            # Some default env vars.
            env = XCURSOR_SIZE,24

            # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
            input {
                kb_layout = us,ru
                kb_options = grp:alt_shift_toggle

                follow_mouse = 1

                touchpad {
                    natural_scroll = no
                }

                sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
            }

            exec-once = hyprland-per-window-layout

            general {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more

                gaps_in = 2
                gaps_out = 3
                border_size = 2
                col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
                col.inactive_border = rgba(595959aa)

                layout = dwindle

                # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
                allow_tearing = false
            }

            decoration {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more

                rounding = 4

                blur {
                    enabled = true
                    size = 3
                    passes = 1
                }

                drop_shadow = yes
                shadow_range = 4
                shadow_render_power = 3
                col.shadow = rgba(1a1a1aee)
            }

            animations {
                enabled = yes

                # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

                bezier = myBezier, 0.05, 0.9, 0.1, 1.05

                animation = windows, 1, 7, myBezier
                animation = windowsOut, 1, 7, default, popin 80%
                animation = border, 1, 10, default
                animation = borderangle, 1, 8, default
                animation = fade, 1, 7, default
                animation = workspaces, 1, 6, default
            }

            dwindle {
                # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
                pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
                preserve_split = yes # you probably want this
            }

            master {
                # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
                # TODO: update with new version
                # new_is_master = true
            }

            gestures {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more
                workspace_swipe = off
            }

            misc {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more
                force_default_wallpaper = -1 # Set to 0 to disable the anime mascot wallpapers
            }

            # Example per-device config
            # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
            # TODO: update with new version
            # device:epic-mouse-v1 {
            #     sensitivity = -0.5
            # }

            # Example windowrule v1
            # windowrule = float, ^(kitty)$
            # Example windowrule v2
            # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
            # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


            # See https://wiki.hyprland.org/Configuring/Keywords/ for more
            $mainMod = SUPER
            $altMod  = CTRL ALT

            # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
            bind = $mainMod, Q, exec, kitty
            bind = $mainMod, C, killactive,
            bind = $mainMod, M, exit,
            bind = $mainMod, V, togglefloating,
            bind = $mainMod, P, pseudo, # dwindle
            bind = $mainMod, J, togglesplit, # dwindle
            bind = $mainMod, L, exec, loginctl lock-session

            # Move focus with mainMod + arrow keys
            bind = $mainMod, left, movefocus, l
            bind = $mainMod, right, movefocus, r
            bind = $mainMod, up, movefocus, u
            bind = $mainMod, down, movefocus, d

            # Switch workspaces with mainMod + [0-9]
            bind = $mainMod, 1, workspace, 1
            bind = $mainMod, 2, workspace, 2
            bind = $mainMod, 3, workspace, 3
            bind = $mainMod, 4, workspace, 4
            bind = $mainMod, 5, workspace, 5
            bind = $mainMod, 6, workspace, 6
            bind = $mainMod, 7, workspace, 7
            bind = $mainMod, 8, workspace, 8
            bind = $mainMod, 9, workspace, 9
            bind = $mainMod, 0, workspace, 10

            # Switch workspaces with altMod + arrows
            bind = $altMod, left,  workspace, m-1
            bind = $altMod, right, workspace, m+1


            # Move active window to a workspace with mainMod + SHIFT + [0-9]
            bind = $mainMod SHIFT, 1, movetoworkspace, 1
            bind = $mainMod SHIFT, 2, movetoworkspace, 2
            bind = $mainMod SHIFT, 3, movetoworkspace, 3
            bind = $mainMod SHIFT, 4, movetoworkspace, 4
            bind = $mainMod SHIFT, 5, movetoworkspace, 5
            bind = $mainMod SHIFT, 6, movetoworkspace, 6
            bind = $mainMod SHIFT, 7, movetoworkspace, 7
            bind = $mainMod SHIFT, 8, movetoworkspace, 8
            bind = $mainMod SHIFT, 9, movetoworkspace, 9
            bind = $mainMod SHIFT, 0, movetoworkspace, 10

            # Move workspace to a monitor with altMod SHIFT + arrows
            bind = $mainMod SHIFT, left,  movecurrentworkspacetomonitor, l
            bind = $mainMod SHIFT, right, movecurrentworkspacetomonitor, r
            bind = $mainMod SHIFT, up,  movecurrentworkspacetomonitor, u
            bind = $mainMod SHIFT, down, movecurrentworkspacetomonitor, d


            # Scroll through existing workspaces with mainMod + scroll
            bind = $mainMod, mouse_down, workspace, e+1
            bind = $mainMod, mouse_up, workspace, e-1

            # Move/resize windows with mainMod + LMB/RMB and dragging
            bindm = $mainMod, mouse:272, movewindow
            bindm = $mainMod, mouse:273, resizewindow

            bind = , f12, exec, hdrop -f -h 90 kitty
            bind = $mainMod, t, exec, hdrop telegram-desktop
            bind = ALT, f3, exec, anyrun
            bind = ALT, f2, exec, anyrun
            bind = $mainMod, f3, exec, anyrun
            bind = $mainMod, f2, exec, anyrun

            bind = ALT, f4, killactive

            bindle=, XF86AudioRaiseVolume, exec, amixer set Master 10%+
            bindle=, XF86AudioLowerVolume, exec, amixer set Master 10%-
            bindle=, XF86MonBrightnessUp, exec, brightnessctl set 10%+
            bindle=, XF86MonBrightnessDown, exec, brightnessctl set 10%-
            bindl=, XF86AudioMute, exec, amixer set Master toggle
            bindl=, XF86AudioPlay, exec, playerctl -a play-pause
            bind = ALT, 7, exec, playerctl play-pause
            bindl=, XF86AudioNext, exec, playerctl next
            bindl=, XF86AudioPrev, exec, playerctl previous

            $hyprshotHk = hyprshot -o "$HOME/Pictures/Screenshots"

            bindl=, Print, exec, $hyprshotHk -m output
            bindl=SHIFT, Print, exec, $hyprshotHk -m region
            bindl=$mainMod, Print, exec, $hyprshotHk -m output -- pinta
            bindl=SHIFT $mainMod, Print, exec, $hyprshotHk -m region -- pinta


            # Window rules
            ## Chrome

            windowrule = float, ^(Google-chrome)$
            windowrule = float, ^(org.gnome.Calculator)$
            windowrule = float, title:^(Sign in to Security Device)$
            windowrule = float, ^(YandexMusic)$
            windowrule = float, ^(pavucontrol)$
          '';
      };
    };
  };
}

