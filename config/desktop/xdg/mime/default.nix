{ lib, ... }:
let
  setApplicationFor =
    app: types:
    with builtins;
    listToAttrs (
      map (type: {
        name = type;
        value = app;
      }) types
    );
  setApplicationsFor =
    cfg:
    with builtins;
    let
      appsList = mapAttrs (app: types: setApplicationFor [ app ] (lib.lists.toList types)) cfg;
      values = attrValues appsList;
    in
    foldl' (all: v: all // v) { } values;
in
{
  hm.xdg.mimeApps = {
    enable = true;
    defaultApplications = setApplicationsFor {
      "org.gnome.Evince.desktop" = "application/pdf";
      "org.gnome.eog.desktop" = [
        "image/*"
        "image/png"
        "image/jpeg"
        "image/jpg"
        "image/gif"
        "image/webp"
        "image/bmp"
      ];
      "neovide.desktop" = [
        "text/*"
        "application/x-shellscript"
        "text/english"
        "text/plain"
        "text/rust"
        "text/x-c"
        "text/x-c++"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-makefile"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
      ];
    };
  };
}
