{
  config,
  lib,
  ...
}:
{
  services.minidlna = lib.mkIf config.hardware.isNas {
    enable = true;
    openFirewall = true;
    #user = config.user.name;
    settings =
      let
        inherit (config.services) mediaStore;
        yes = "yes";
      in
      {
        media_dir = [
          "V,${mediaStore}/Videos/Movies"
          "V,${mediaStore}/Videos/Cartoon_Movies"
          "V,${mediaStore}/Videos/TV"
          "V,${mediaStore}/Videos/Cartoon_Series"
          "A,${mediaStore}/Music"
          "P,${mediaStore}/Photos"
        ];
        inotify = yes;
        wide_links = yes;
      };
  };
}
