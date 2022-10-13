{ pkgs, ... }:
with pkgs;
let
  bbname = "BluePill";
  usage = ''
    This will controls gpio pins of your stm32 blue pill, flashed with firmware
    from here: https://github.com/ein-shved/GpioUsb

    usage:
    $0 <cmd> <reg> <pin> [ <arg> ]

    <cmd> can be one of:

    * up - pull pin(s) up
    * down - pull pin(s) down
    * toggle - toggle pin(s)
    * init - initialize pin(s) with one of out or in passed with <arg>
    * deinit - deinitialize pin(s)

    The <reg> can be a letter from a to e, denoting corresponding port

    The <pin> can be in one of next forms:

    * <pin number> - the number of pin port from 0 to 15
    * m<pin mask> - the mask of pins predeceased by m letter in bounds from 0 to 0xffff

    Each number can be in decimal, octal (with leading 0) or hexadecimal (with leading 0x) form.
  '';
  st-gpio = pkgs: pkgs.writeShellScriptBin "st-gpio" ''
    set -e
    if [ "$1" == "help" ] || [ -z "$1" ]; then
      echo "${usage}"
      exit 0
    fi

    dev="$(eval echo "/dev/${bbname}_*" | sed 's/\s/\n/' | head -1)"

    ${pkgs.coreutils}/bin/stty -F "$dev"  115200 -icrnl && exec echo "$@" > $dev
  '';
in
{
  config = {
    nixpkgs.overlays = [(self: super: { st-gpio = st-gpio self; })];
    environment.systemPackages = [
        stm32cubemx
        stlink
        pkgs.st-gpio
    ];
    services.udev.extraRules = ''
      # ST-LINK V2
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
        MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2_%n"

      # ST-LINK V2.1
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
        MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", \
        MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"

      # ST-LINK V3
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", \
        MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3loader_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", \
        MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", \
        MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", \
        MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", \
        MODE="660", TAG+="uaccess", SYMLINK+="${bbname}_%n"
    '';
  };
}
