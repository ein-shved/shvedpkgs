{ config, pkgs, lib, ... }:
let
  cfg = config.user;
  mkDomainName = name: hasNs:
    let
      sName = lib.splitString " " name;
      fname = builtins.elemAt sName 0;
      sname = builtins.elemAt sName 1;
      fn = builtins.elemAt (lib.stringToCharacters fname) 0;
    in
    if hasNs then sname + "_" + fn else sname;
in
{

  ## Options #######################################

  options = {
    user = with pkgs.lib; with types; {

      name = mkOption {
        description = "Default user login string";
        type = str;
      };

      humanName = mkOption {
        description = "Introduce yourself";
        type = str;
        default = cfg.name;
      };

      home = mkOption {
        description = "Homedir";
        type = str;
        default = "/home/${cfg.name}";
      };

      password = mkOption {
        description = ''
          Specifies the clear text password for the account. This password
          will be copied to the Nix store, and will be visible to all local
          users
        '';
        type = nullOr str;
        default = null;
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
        default = [ ];
      };

      mail = mkOption {
        description = "User e-mail";
        type = types.nullOr types.str;
        default =
          if config.local.kl.enable
          then config.local.kl.mail
          else null;
      };

    };
  };


  ## Configurations #######################################

  config = {
    users.users = {
      ${cfg.name} = {
        inherit (cfg) home name password;
        createHome = true;
        isNormalUser = true;
        extraGroups = [
          "wheel" # Admin
          "tty" # Can configure tty devices
          "dialout" # Can configure tty devices
          "keys"
          "audio" # Allow pulseaudio control
          "adbusers" # Can start adb daemon
          "docker" # Can interact with docker containers
        ] ++ cfg.extraGroups;
      };
    };
  };
}
