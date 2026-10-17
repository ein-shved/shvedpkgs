let
  flake = builtins.getFlake (toString ../..);
  lib = flake.inputs.nixpkgs.lib;
  snapshot =
    host:
    let
      cfg = host.config;
      login = cfg.user.name;
      account = cfg.users.users.${login};
      home = cfg.home-manager.users.${login};
    in
    {
      inherit login;
      homeEnabled = cfg.home.enable;
      account = {
        inherit (account)
          name
          home
          description
          isNormalUser
          createHome
          password
          ;
        extraGroups = lib.sort builtins.lessThan account.extraGroups;
      };
      hm = {
        inherit (home.home) username homeDirectory stateVersion;
        inherit (cfg.home-manager) useGlobalPkgs;
        activation = builtins.attrNames home.home.activation;
      };
      secondary = builtins.removeAttrs (lib.mapAttrs (_: u: {
        inherit (u)
          name
          home
          isNormalUser
          isSystemUser
          ;
      }) cfg.users.users) [ login ];
      features = {
        vps = cfg.hardware.isVps;
        gerrit = cfg.services.gerrit.enable;
        gerritUnit = cfg.systemd.services ? gerrit;
        gerritFirewall = builtins.elem 29418 cfg.networking.firewall.allowedTCPPorts;
        gaming = cfg.environment.gaming.enable;
        steam = cfg.programs.steam.enable;
        gamingController = builtins.elem "hid-playstation" cfg.boot.kernelModules;
        steamRemotePlay = cfg.programs.steam.remotePlay.openFirewall;
        kl = cfg.kl.enable;
        graphical = cfg.hardware.isGraphic;
        klTrust = cfg.kl.trust.enable;
        klNssCertificates = cfg.kl.nss.certificates.enable;
        klNssTokens = cfg.kl.nss.tokens.enable;
        nssActivation = {
          certificates = home.home.activation ? installNssDbCerts;
          tokens = home.home.activation ? installNssDbKeys;
        };
        development = cfg.hardware.isDevelopment;
        wakeOnPowerButtonOnly = cfg.hardware.power.wakeOnPowerButtonOnly.enable;
        cifsKeyutils = cfg.services.cifsKeyutils.enable;
        avr = cfg.hardware.programmers.avr.enable;
        stm32 = cfg.hardware.programmers.stm32.enable;
        wakeUnit = cfg.systemd.services ? wakeOnPowerButtonOnly;
        requestKey = cfg.environment.etc ? "request-key.conf";
        programmerRules = {
          avr = lib.hasInfix "05dc" cfg.services.udev.extraRules;
          stm32 = lib.hasInfix "stlinkv3" cfg.services.udev.extraRules;
        };
        logind = cfg.services.logind.settings.Login;
        openssh = cfg.services.openssh.enable;
        transmission = cfg.services.transmission.enable;
        displayManager = cfg.services.displayManager.enable;
        git = cfg.programs.git.enable;
        certificates = map toString cfg.security.pki.certificateFiles;
      };
    };
in
lib.mapAttrs (_: snapshot) flake.nixosValidationConfigurations
