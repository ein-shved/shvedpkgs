{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.user;
in
{

  ## Options #######################################

  options = {
    user = with types; {
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

      domainName = mkOption {
        description = "User login in domain";
        type = str;
        default = cfg.domainNameMaker cfg.humanName;
      };

      domainNameMaker = mkOption {
        description = "Function which makes domain name from human name";
        type = functionTo str;
        default = name: lib.getSurname (lib.toLower name);
      };

      extraGroups = mkOption {
        description = "Extra groups for user";
        type = types.listOf str;
        default = [ ];
      };

      mail = mkOption {
        description = "User e-mail";
        type = types.nullOr types.str;
        default = null;
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
        description = cfg.humanName;
        extraGroups = [
          "wheel" # Admin
          "tty" # Can configure tty devices
          "dialout" # Can configure tty devices
          "keys"
          "audio" # Allow pulseaudio control
          "adbusers" # Can start adb daemon
          "docker" # Can interact with docker containers
          "input" # Access to input devices
          "nixbld" # Access to nix build files
        ]
        ++ cfg.extraGroups;
      };
    };
  };
}
