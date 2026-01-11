{ pkgs, ... }:
{
  hm.programs.anyrun = {
    enable = true;
    config = {
      x = {
        fraction = 0.5;
      };

      y = {
        absolute = 0;
      };

      width = {
        absolute = 800;
      };

      hideIcons = false;

      ignoreExclusiveZones = false;

      layer = "overlay";

      hidePluginInfo = false;

      closeOnClick = true;
      showResultsImmediately = false;
      maxEntries = null;

      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libnix_run.so"
        "${pkgs.anyrun}/lib/libniri_focus.so"
      ];

    };
    extraConfigFiles."shell.ron".text = ''
      Config(
        prefix: "!",
        shell: None,
      )
    '';
    extraConfigFiles."nix-run.ron".text = ''
      Config(
        prefix: ":nr",
        allow_unfree: false,
        channel: "nixpkgs",
        max_entries: 3,
      )
    '';
    extraCss = ''
      @define-color accent #5599d2;
      @define-color bg-color alpha(#030303, 0.8);
      @define-color fg-color #eeeeee;
      @define-color desc-color #cccccc;

      window {
        background: transparent;
      }

      box.main {
        padding: 5px;
        margin: 10px;
        border-radius: 10px;
        border: 4px solid @accent;
        background-color: @bg-color;
        box-shadow: 0 0 5px black;
      }


      text {
        min-height: 30px;
        padding: 5px;
        border-radius: 5px;
        color: @fg-color;
      }

      .matches {
        background-color: rgba(0, 0, 0, 0);
        border-radius: 10px;
      }

      box.plugin:first-child {
        margin-top: 5px;
      }

      box.plugin.info {
        min-width: 200px;
      }

      list.plugin {
        background-color: rgba(0, 0, 0, 0);
      }

      label.match {
        color: @fg-color;
      }

      label.match.description {
        font-size: 10px;
        color: @desc-color;
      }

      label.plugin.info {
        font-size: 14px;
        color: @fg-color;
      }

      .match {
        background: transparent;
      }

      .match:selected {
        border: 4px solid @accent;
        border-radius: 6px;
        background: transparent;
        animation: fade 0.1s linear;
      }

      @keyframes fade {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1;
        }
      }
    '';
  };
}
