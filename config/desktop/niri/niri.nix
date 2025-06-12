{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    elemAt
    splitString
    removePrefix
    mapAttrs
    mapAttrs'
    nameValuePair
    map
    toList
    length
    toInt
    optional
    optionalAttrs
    ;
  user = config.user.name;
  nirilib = config.home-manager.users.${user}.lib.niri;
  monitors = config.hardware.aliasedMonitors;
  mkOutput =
    name: monitor:
    let
      optionalAttr = pred: val: if pred then val else null;
      optionalIntAttr =
        name: optionalAttr (monitor ? "${name}") (toInt monitor."${name}");
      name' = removePrefix "desc:" name;
      position =
        let
          splitted = splitString "x" monitor.position;
        in
        optionalAttr (monitor ? position && length splitted > 1) {
          x = toInt (elemAt splitted 0);
          y = toInt (elemAt splitted 1);
        };
      mode =
        let
          splitted = splitString "x" monitor.resolution;
        in
        optionalAttr (monitor ? resolution && length splitted > 1) {
          width = toInt (elemAt splitted 0);
          height = toInt (elemAt splitted 1);
          # TODO(Shvedov): parse refresh
        };
      scale = optionalIntAttr "scale";
      transform = monitor.transform or { };
      output = {
        inherit
          position
          mode
          scale
          transform
          ;
        inherit (monitor) enable;
      };
    in
    nameValuePair name' output;
  outputs = mapAttrs' mkOutput monitors;
  singleOutput = config.hardware.singleOutput;

  locker = toString (
    pkgs.writeShellScript "lock-session" ''
      playerctl -a pause
      hyprlock
    ''
  );
in
{
  programs.niri = {
    enable = config.hardware.needGraphic;
    package = pkgs.niri;
  };
  home-manager.users.${user}.programs.niri.settings = {
    inherit outputs;

    input.keyboard = {
      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle,ctrl:nocaps";
      };
      track-layout = "window";
    };

    layout = {
      gaps = 8;
      center-focused-column = "never";
      default-column-width.proportion = 0.5;
      preset-column-widths = [
        { proportion = 1. / 2.; }
        { proportion = 1.; }
      ];
    };

    window-rules = [
      {
        geometry-corner-radius = {
          bottom-left = 6.;
          bottom-right = 6.;
          top-left = 6.;
          top-right = 6.;
        };
        clip-to-geometry = true;
      }
      {
        matches = [
          { is-focused = false; }
        ];
        opacity = 0.8;
      }
    ];
    prefer-no-csd = true;

    spawn-at-startup =
      let
        spawns = map (spawnie: {
          command = toList spawnie;
        });
      in
      spawns (
        (optional singleOutput.enable [
          "niri-single-output"
          "init"
        ])
        ++ [
          locker
          "waybar"
          [
            "wayidle"
            "--timeout"
            "600"
            locker
          ]
          "wpaperd"
          "swaync"
          "udiskie"
          [
            "xwayland-satellite"
            ":0"
          ]
        ]
      );

    environment = {
      GTK_THEME = "Adwaita:dark";
      QT_QPA_PLATFROM = "wayland";
      NIXOS_OZONE_WL = "1";
      DISPLAY = ":0"; # We run xwayland-satellite
    };

    binds =
      let
        inherit (nirilib) actions;
        spawns = mapAttrs (name: spawnie: { action.spawn = spawnie; });
        acts = mapAttrs (name: actie: { action = actie; });
        focus-workspace-at = key: ws: {
          "Mod+${builtins.toString key}".action.focus-workspace = ws;
        };
        focus-workspace =
          ws: if ws == 10 then focus-workspace-at 0 ws else focus-workspace-at ws ws;
        focus-workspaces =
          workspaces: lib.foldl' (all: ws: all // focus-workspace ws) { } workspaces;
        toggle-play = [
            "playerctl"
            "-a"
            "play-pause"
          ];
      in
      (acts (
        with actions;
        {
          "Mod+Shift+Slash" = show-hotkey-overlay;
          "Mod+Shift+E" = quit;

          "Mod+Q" = close-window;
          "Mod+C" = close-window;
          "Alt+F4" = close-window;

          "Mod+Up" = focus-window-or-workspace-up;
          "Mod+Down" = focus-window-or-workspace-down;
          "Mod+Left" = focus-column-left;
          "Mod+Right" = focus-column-right;

          "Mod+Shift+Up" = move-window-up-or-to-workspace-up;
          "Mod+Shift+Down" = move-window-down-or-to-workspace-down;
          "Mod+Shift+Left" = move-column-left;
          "Mod+Shift+Right" = move-column-right;

          "Mod+Ctrl+Up" = focus-monitor-up;
          "Mod+Ctrl+Down" = focus-monitor-down;
          "Mod+Ctrl+Left" = focus-monitor-left;
          "Mod+Ctrl+Right" = focus-monitor-right;

          "Mod+Shift+Ctrl+Up" = move-window-to-monitor-up;
          "Mod+Shift+Ctrl+Down" = move-window-to-monitor-down;
          "Mod+Shift+Ctrl+Left" = move-window-to-monitor-left;
          "Mod+Shift+Ctrl+Right" = move-window-to-monitor-right;

          "Mod+Alt+Up" = move-workspace-up;
          "Mod+Alt+Down" = move-workspace-down;

          "Mod+Alt+Ctrl+Up" = move-workspace-to-monitor-up;
          "Mod+Alt+Ctrl+Down" = move-workspace-to-monitor-down;
          "Mod+Alt+Ctrl+Left" = move-workspace-to-monitor-left;
          "Mod+Alt+Ctrl+Right" = move-workspace-to-monitor-right;

          "Mod+F" = switch-preset-column-width;

          "Shift+Print" = screenshot;
          # TODO(Shvedov): This action was deprecated. Find replacement
          # "Print" = screenshot-screen;

          "Mod+H" = switch-focus-between-floating-and-tiling;
          "Mod+Shift+H" = toggle-window-floating;
          "Mod+P" = toggle-overview;
        }
      ))
      // (spawns (
        {
          "Mod+T" = [
            "niri-launcher"
            "kitty"
          ];
          "F12" = "niri-launch-terminal";

          "Alt+F2" = "anyrun";
          "Alt+F3" = "anyrun";
          "Mod+D" = "anyrun";
          "Mod+L" = locker;

          "XF86AudioRaiseVolume" = [
            "amixer"
            "set"
            "Master"
            "10%+"
          ];
          "XF86AudioLowerVolume" = [
            "amixer"
            "set"
            "Master"
            "10%-"
          ];
          "XF86MonBrightnessUp" = [
            "brightnessctl"
            "set"
            "10%+"
          ];
          "XF86MonBrightnessDown" = [
            "brightnessctl"
            "set"
            "10%-"
          ];
          "XF86AudioMute" = [
            "amixer"
            "set"
            "Master"
            "toggle"
          ];
          "XF86AudioPlay" = toggle-play;
          "ALT+7" = toggle-play;
          "Mod+7" = toggle-play;
          "XF86AudioNext" = [
            "playerctl"
            "next"
          ];
          "XF86AudioPrev" = [
            "playerctl"
            "previous"
          ];

          # Open notifications panel
          "Mod+N" = [
            "swaync-client"
            "-t"
          ];
          # Clear notifications and close panel
          "Mod+Shift+N" =
            let
              clear-close = pkgs.writers.writeBash "clear-close-swaync" ''
                swaync-client -C
                swaync-client -cp
              '';
            in
            "${clear-close}";
        }
        // optionalAttrs singleOutput.enable {
          "Mod+O" = [
            "niri-single-output"
            "next"
          ];
        }
      ));
    cursor.hide-when-typing = true;
    gestures.hot-corners.enable = false;
  };
}
