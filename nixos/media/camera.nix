{ pkgs, lib, config, ... }:
{
  config.local.udev = {
    extraRules = [
      ''
        SUBSYSTEM=="usb", \
        ATTRS{idVendor}=="045e", \
        ATTRS{idProduct}=="076d", \
        GROUP="dialout", \
        RUN+="${pkgs.v4l-utils}/bin/v4l2-ctl -c focus_auto=0 -c focus_absolute=10"
      ''
    ];
  };
}
