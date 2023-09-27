{ pkgs, ... }:
let
  bbname = "BluePill";
  bmonster = "bmonster";

  usage_legacy = ''
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

  usage_bmonster = ''
    Usage: $1 [pin-name|all|free|blocked|occupied|uartN [command [command_ops]]]
    pin-name is [gpio_][pin_][p]XN, where X is port name a|b|c, N is pin number in port
            all(default):   apply command to all gpio pins
            free:           apply command to all free pins
            blocked:        apply command to all blocked pins
            occupied:       apply command to all occupied pins
            uartN:          apply command to all pins, which may be used by uartN, N is one of 1,2,3
            led:            alias for pb13
            shell:
            control:
            config:         aliases for pb5
    commands are:
            show(default):  show current usage of pin
            free:           make pin free from uart port
            occupy:         attach pin to its uart port
            get:            get value of pin if available
            up:             set free pin up
            down:           set free pin down
            set [help|config...]: set configuration value of free pin
    Example: "gpio" shows all gpio pins and their status
    Example: "gpio all free" detach all non-blocked pins from their functions
    Example: "uart pin_a10 up" sets gpio pin pa10 up
  '';

  st-gpio = pkgs: pkgs.writeShellScriptBin "st-gpio" ''
    set -e
    legacy=0
    prefix="gpio "
    dev="/dev/${bmonster}_control"
    if ! [ -e $dev ]; then
      dev="$(eval echo "/dev/${bbname}_*" | sed 's/\s/\n/' | head -1)"
      if [ -e "$dev" ]; then
        prefix=""
        legacy=1
      fi
    fi

    if [ "$1" == "help" ] || [ -z "$1" ]; then
      if [ $legacy == 1 ]; then
        echo "${usage_legacy}"
      else
        echo "${usage_bmonster}"
      fi
      exit 0
    fi


    ${pkgs.coreutils}/bin/stty -F "$dev"  115200 -icrnl && exec echo "$prefix""$@" > $dev
  '';

in
{
  config = {
    nixpkgs.overlays = [(self: super: { st-gpio = st-gpio self; })];
    environment.systemPackages = with pkgs; [
      stm32cubemx
      stlink
      pkgs.st-gpio
    ];
    services.udev.extraRules = ''
      # ST-LINK V2
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
        MODE="660", TAG+="uaccess", GROUP="tty", SYMLINK+="stlinkv2_%n"

      # ST-LINK V2.1
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
        MODE="660", TAG+="uaccess", GROUP="tty", SYMLINK+="stlinkv2-1_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", \
        MODE="660", TAG+="uaccess", GROUP="tty", SYMLINK+="stlinkv2-1_%n"

      # ST-LINK V3
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", \
        MODE="660", TAG+="uaccess", GROUP="tty", SYMLINK+="stlinkv3loader_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", \
        MODE="660", TAG+="uaccess", GROUP="tty", SYMLINK+="stlinkv3_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", \
        MODE="660", TAG+="uaccess", GROUP="tty", SYMLINK+="stlinkv3_%n"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", \
        MODE="660", TAG+="uaccess", GROUP="tty", SYMLINK+="stlinkv3_%n"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", \
        MODE="660", TAG+="uaccess", SYMLINK+="${bbname}_%n"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="fffe", \
        GOTO="bb_serial_monster"

      SUBSYSTEMS=="usb" GOTO="bb_serial_monster_end"

      LABEL="bb_serial_monster"

      SUBSYSTEMS=="usb", ATTRS{bInterfaceNumber}=="00", \
        MODE="660", TAG+="uaccess", \
        SYMLINK+="${bmonster}_1", SYMLINK+="${bmonster}_control", \
        TAG+="${bmonster}_1"

      SUBSYSTEMS=="usb", ATTRS{bInterfaceNumber}=="02", \
        MODE="660", TAG+="uaccess", \
        SYMLINK+="${bmonster}_2", \
        TAG+="${bmonster}_2"

      SUBSYSTEMS=="usb", ATTRS{bInterfaceNumber}=="04", \
        MODE="660", TAG+="uaccess", \
        SYMLINK+="${bmonster}_3", \
        TAG+="${bmonster}_3"

      LABEL="bb_serial_monster_end"
    '';
  };

}

