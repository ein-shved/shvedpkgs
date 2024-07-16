{ config
, ...
}:
let
  user = config.user.name;
in
{
  home-manager.users.${user}.programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = {
      topBar = {
        position = "top"; # Waybar position (top|bottom|left|right)
        height = 36; # Waybar height (to be removed for auto height)
        exclusive = true;
        # "width": 1280 # Waybar width
        spacing = 4; # Gaps between modules (4px)
        fixed-center = false;
        # Choose the order of the modules
        modules-left = [
          "hyprland/workspaces"
          # "custom/media"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "temperature"
          #"keyboard-state"
          "battery"
          "clock"
          "hyprland/language"
          "tray"
          #"custom/power"
        ];
        keyboard-state = {
          numlock = true;
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = " ";
            unlocked = " ";
          };
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        tray = {
          icon-size = 28;
          spacing = 10;
        };
        clock = {
          # "timezone": "America/New_York"
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        memory = {
          format = "{}% ";
        };
        temperature = {
          # "thermal-zone": 2
          # "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input"
          critical-threshold = 80;
          # "format-critical": "{temperatureC}°C {icon}"
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" ];
        };
        battery = {
          states = {
            # "good": 95
            warning = 30;
            critical = 15;
          };
          format = "{capacity}%{icon}";
          format-full = "Full{icon}";
          format-charging = "{capacity}%󱐋{icon}";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          # "format-good": "" # An empty format will hide the module
          # "format-full": ""
          format-icons = [ " " " " " " " " " " ];
        };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = " ";
            performance = " ";
            balanced = " ";
            power-saver = " ";
          };
        };
        network = {
          format-wifi = " {signalStrength}%";
          tooltip-format-wifi = "{essid} 󱘖 {gwaddr}";

          format-ethernet = "󰌘";
          tooltip-format-ethernet = "{ifname} 󱘖 {gwaddr}";

          format-linked = "󰌗";
          tooltip-format-linked = "No address";

          format-disconnected = "󰌙";
          tooltip-format-disconnected = "Offline";
        };
        pulseaudio = {
          # "scroll-step": 1 # % can be a float
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon}  {format_source}";
          format-bluetooth-muted = " {icon}  {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "󱡏";
            headset = "󰋎";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        # TODO(Shvedov)
        # "custom/media" = {
        #   format = "{icon} {}";
        #   return-type = "json";
        #   max-length = 40;
        #   format-icons = {
        #     spotify = "";
        #     default = "🎜";
        #   };
        #   escape = true;
        #   exec = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder;
        #   # "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
        # };
        #"custom/power" = {
        #  format = "⏻ ";
        #  tooltip = false;
        #  menu = "on-click";
        #  menu-file = ./power_menu.xml; # Menu file in resources folder
        #  menu-actions = {
        #    shutdown = "shutdown";
        #    reboot = "reboot";
        #    suspend = "systemctl suspend";
        #    hibernate = "systemctl hibernate";
        #  };
        #};
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
          };
        };
        "hyprland/language" = {
          format = "{}";
          format-en = "EN";
          format-ru = "RU";
        };
      };
    };
  };
}
