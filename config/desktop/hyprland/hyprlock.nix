{ config, pkgs, lib, ... }:
let
  monitors = config.programs.hyprland.monitors;
in
{
  config.programs.hyprland.hyprconfig.hyprlock = {
    text =
      let
        mkMonitor = name: lib.optionalString (name != "default") name;
        mkBackground = name: value: ''
          background {
            monitor = ${mkMonitor name}
            path = ${value.wallpaper}
            blur_passes = 1
          }
        '';
        backgrounds = lib.foldlAttrs
          (acc: name: value: acc + (mkBackground name value))
          ""
          (lib.filterAttrs
            (name: value: value ? wallpaper && value.wallpaper != null)
            monitors);

      in
      ''
        ${backgrounds}

        input-field {
            monitor =
            size = 500, 50
            outline_thickness = 3
            dots_size = 0.33 # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = false
            dots_rounding = -1 # -1 default circle, -2 follow input-field rounding
            outer_color = rgb(151515)
            inner_color = rgb(200, 200, 200)
            font_color = rgb(10, 10, 10)
            fade_on_empty = true
            fade_timeout = 1000 # Milliseconds before fade_on_empty is triggered.
            placeholder_text = <i>Input Password...</i> # Text rendered in the input box when it's empty.
            hide_input = false
            rounding = -1 # -1 means complete rounding (circle/oval)
            check_color = rgb(204, 136, 34)
            fail_color = rgb(204, 34, 34) # if authentication failed, changes outer_color and fail message color
            fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i> # can be set to empty
            fail_timeout = 2000 # milliseconds before fail_text and fail_color disappears
            fail_transition = 300 # transition time in ms between normal outer_color and fail_color
            capslock_color = -1
            numlock_color = -1
            bothlock_color = -1 # when both locks are active. -1 means don't change outer color (same for above)
            invert_numlock = false # change color if numlock is off
            swap_font_color = false # see below

            position = 0, -20
            halign = center
            valign = center
        }

        label {
            monitor =
            text = Hi there, $USER
            text_align = center # center/right or any value for default left. multi-line text alignment inside label container
            color = rgba(200, 200, 200, 1.0)
            font_size = 25
            font_family = Noto Sans
            rotate = 0 # degrees, counter-clockwise

            position = 0, 80
            halign = center
            valign = center
        }

        label {
            monitor =
            text = $LAYOUT
            text_align = right # center/right or any value for default left. multi-line text alignment inside label container
            color = rgba(200, 200, 200, 1.0)
            font_size = 18
            font_family = Noto Sans
            rotate = 0 # degrees, counter-clockwise

            position = -10, -19
            halign = right
            valign = top
        }
      '';
  };
}

