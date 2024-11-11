{ config, pkgs, lib, ... }:
let
  device =
    let
      vals = lib.attrValues config.boot.initrd.luks.devices;
    in
    if builtins.length vals == 0
    then null
    else (builtins.elemAt vals 0).device;

  mkUpdater = name: cmd: pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [ cryptsetup ];
    text = ''
      SUDO=""
      if [ "$USER" != "root" ]; then
        SUDO="sudo";
      fi
      exec $SUDO cryptsetup ${cmd} ${device}
    '';
  };
in
{
  config.environment = lib.mkIf (device != null) {
    systemPackages = [
      (mkUpdater "diskAddKey" "luksAddKey")
      (mkUpdater "diskRemoveKey" "luksRemoveKey")
    ];
  };
}
