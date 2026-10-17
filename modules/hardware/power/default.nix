{ config, lib, ... }:
{
  options.hardware.power.wakeOnPowerButtonOnly.enable =
    lib.mkEnableOption "wake only on the power button";
  config = lib.mkIf config.hardware.power.wakeOnPowerButtonOnly.enable {
    systemd.services.wakeOnPowerButtonOnly = {
      # Wake up only on pressing power key
      script = ''
        for x in $(grep enabled /proc/acpi/wakeup | cut -f1 |\
                    grep -v 'PBTN\|PWRB' | grep -v platform)
        do
          echo $x > /proc/acpi/wakeup
        done
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
}
