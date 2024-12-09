{ ... }:
{
  home.xdg.configFile = {
    "anyrun/config.ron" = {
      text = ''
        Config(
          // Position/size fields use an enum for the value, it can be either:
          // Absolute(n): The absolute value in pixels
          // Fraction(n): A fraction of the width or height of the full screen (depends on exclusive zones and the settings related to them) window respectively

          // The horizontal position, adjusted so that Relative(0.5) always centers the runner
          x: Fraction(0.5),

          // The vertical position, works the same as `x`
          y: Absolute(0),

          // The width of the runner
          width: Absolute(800),

          // The minimum height of the runner, the runner will expand to fit all the entries
          height: Absolute(0),

          // Hide match and plugin info icons
          hide_icons: false,

          // ignore exclusive zones, f.e. Waybar
          ignore_exclusive_zones: false,

          // Layer shell layer: Background, Bottom, Top, Overlay
          layer: Overlay,

          // Hide the plugin info panel
          hide_plugin_info: false,

          // Close window when a click outside the main box is received
          close_on_click: false,

          // Show search results immediately when Anyrun starts
          show_results_immediately: false,

          // Limit amount of entries shown in total
          max_entries: None,

          // List of plugins to be loaded by default, can be specified with a relative path to be loaded from the
          // `<anyrun config dir>/plugins` directory or with an absolute path to just load the file the path points to.
          plugins: [
            "libapplications.so",
            "libshell.so",
         ],
        )
      '';
    };
    "anyrun/shell.ron" = {
      text = ''
        Config(
          prefix: "!",
          shell: None,
        )
      '';
    };
    "anyrun/style.css" = {
      text = ''
        * {
            border:        none;
            border-radius: 0;
            font-family:   "JetBrainsMono Nerd Font";
            font-weight:   bold;
            font-size:     15px;
            box-shadow:    none;
            text-shadow:   none;
            transition-duration: 0s;
        }

        #window,
        #match,
        #entry,
        #plugin,
        #main {
          background: transparent;
        }

        #match.activatable {
          border-radius: 8px;
          margin: 4px 0;
          padding: 4px;
          transition: 100ms ease-out;
        }
        #match.activatable:first-child {
          margin-top: 12px;
        }
        #match.activatable:last-child {
          margin-bottom: 0;
        }

        #match:hover {
          background: rgba(255, 255, 255, 0.05);
        }
        #match:selected {
          background: rgba(255, 255, 255, 0.1);
        }

        #entry {
          background: rgba(255, 255, 255, 0.05);
          border: 1px solid rgba(255, 255, 255, 0.1);
          border-radius: 8px;
          padding: 4px 8px;
        }

        box#main {
          background: rgba(0, 0, 0, 0.5);
          box-shadow:
            inset 0 0 0 1px rgba(255, 255, 255, 0.1),
            0 30px 30px 15px rgba(0, 0, 0, 0.5);
          border-radius: 20px;
          padding: 12px;
        }
      '';
    };
  };
}
