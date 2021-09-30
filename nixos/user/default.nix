{ config, pkgs, lib, ... }:
let
  cfg = config.local.user;
  mkDomainName = name: hasNs:
    let
      sName = lib.splitString " " name;
      fname = builtins.elemAt sName 0;
      sname = builtins.elemAt sName 1;
      fn = builtins.elemAt (lib.stringToCharacters fname) 0;
    in
      if hasNs then sname + "_" + fn else sname;
in
 with pkgs.lib; with types; {
  options = {
    local = {
      user = {
        login = mkOption {
          description = "Default user login string";
          type = str;
        };
        name = mkOption {
          description = "Introduce yourself";
          type = str;
        };
        home = mkOption {
          description = "Homedir";
          type = str;
          default = "/home/${cfg.login}";
        };
        hasNamesake = mkOption {
          type = bool;
          description = "Does employee has surnamesake";
          default = false;
        };
        domainName = mkOption {
          description = "User login in domain";
          type = str;
          default = mkDomainName cfg.name cfg.hasNamesake;
        };
        extraGroups = mkOption {
          description = "Extra groups for user";
          type = types.listOf str;
          default = [];
        };
        mail = mkOption {
          description = "User e-mail";
          type = types.nullOr types.str;
          default = if config.local.kl.enable
                    then config.local.kl.mail
                    else null;
        };
      };
    };
  };
  config = {
    users.users = {
      "${cfg.login}" = {
        createHome = true;
        isNormalUser = true;
        home = cfg.home;
        description = cfg.name;
        extraGroups = [
          "wheel"       # Admin
          "tty"         # Can configure tty devices
          "dialout"     # Can configure tty devices
          "keys"
          "audio"       # Allow pulseaudio control
          "adbusers"    # Can start adb daemon
          "docker"      # Can interact with docker containers
        ] ++ cfg.extraGroups;
      };
    };
  };
  imports = [
    ./homedir.nix
  ];
}
