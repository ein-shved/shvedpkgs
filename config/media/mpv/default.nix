{ pkgs, config, ... }:
let
in
{
  config = {
    home.home.file = {
      ".config/mpv/mpv.conf" = {
        text = ''
          save-position-on-quit
        '';
      };
    };
    nixpkgs.overlays = [
      (self: super: {
        mpv = super.mpv.override {
          scripts = [ self.mpvScripts.mpris ];
        };
      })
    ];
  };
}
