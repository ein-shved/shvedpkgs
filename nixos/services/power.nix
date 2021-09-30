{ config, pkgs, ... }:
{
  config = {
    services = {
# Suspend on pressing power key
      logind.extraConfig = ''
        HandlePowerKey=suspend
      '';
    };
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
