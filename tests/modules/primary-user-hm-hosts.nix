let
  flake = builtins.getFlake "git+file://${toString ../..}";
  lib = flake.inputs.nixpkgs.lib;
  snapshot =
    host:
    let
      cfg = host.config;
      login = cfg.user.name;
      account = cfg.users.users.${login};
      home = cfg.home-manager.users.${login} or null;
      gitPackages = with host.pkgs; [
        gitFull
        git-lfs
        gitaliases
        git-review
        git-autofixup
      ];
      developmentPackages = with host.pkgs; [
        file
        inotify-tools
        jq
        stdmanpages
      ];
      desktopPackages = with host.pkgs; [
        dconf
        fontconfig
        hicolor-icon-theme
        sound-theme-freedesktop
        starship
        (pass.withExtensions (exts: [ exts.pass-otp ]))
      ];
      vpsPackages = with host.pkgs; [
        binutils
        cifs-utils
        dhcps
        minicom
        sshfs
        usbutils
      ];
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
      hm =
        if home == null then
          null
        else
          {
            inherit (home.home) username homeDirectory stateVersion;
            inherit (cfg.home-manager) useGlobalPkgs;
            activation = builtins.attrNames home.home.activation;
            git = home.programs.git.enable;
          };
      homeManagerUsers = builtins.attrNames cfg.home-manager.users;
      homeManagerServices = lib.filter (lib.hasPrefix "home-manager-") (
        builtins.attrNames cfg.systemd.services
      );
      gitPackages = map (pkg: {
        name = lib.getName pkg;
        installed = builtins.elem (toString pkg) (map toString cfg.environment.systemPackages);
      }) gitPackages;
      developmentPackages = map (pkg: {
        name = lib.getName pkg;
        installed = builtins.elem (toString pkg) (map toString cfg.environment.systemPackages);
      }) developmentPackages;
      desktopPackages = map (pkg: {
        name = lib.getName pkg;
        installed = builtins.elem (toString pkg) (map toString cfg.environment.systemPackages);
      }) desktopPackages;
      vpsPackages = map (pkg: {
        name = lib.getName pkg;
        installed = builtins.elem (toString pkg) (map toString cfg.environment.systemPackages);
      }) vpsPackages;
      vpsFeatures = {
        cifs = cfg.services.cifsKeyutils.enable;
      };
      desktopFeatures = {
        avahi = cfg.services.avahi.enable;
        pass = cfg.programs.pass.enable;
        gpgAgent = cfg.programs.gnupg.agent.enable;
        translate = cfg.programs.translate-shell.enable;
        starship = cfg.programs.starship.enable;
        powerProfiles = cfg.services.power-profiles-daemon.enable;
        upower = cfg.services.upower.enable;
        udisks = cfg.services.udisks2.enable;
        icons = cfg.xdg.icons.enable;
        sounds = cfg.xdg.sounds.enable;
        fontconfig = cfg.fonts.fontconfig.enable;
      };
      avahi = {
        inherit (cfg.services.avahi) nssmdns4 openFirewall;
        nssModule = builtins.elem (toString host.pkgs.nssmdns) (map toString cfg.system.nssModules.list);
        nssHosts = builtins.any (lib.hasPrefix "mdns") cfg.system.nssDatabases.hosts;
        unit = cfg.systemd.services ? avahi-daemon;
      };
      editor = {
        command = cfg.environment.variables.EDITOR;
        configured = builtins.elem (toString (
          if cfg.hardware.isDevelopment then host.pkgs.vim-configured else host.pkgs.vim-configured-nodev
        )) (map toString cfg.environment.systemPackages);
        neovideContribution = builtins.any (
          pkg: lib.getName pkg == "neovide"
        ) cfg.environment.graphicPackages;
        nano =
          cfg.programs.nano.enable
          && builtins.elem (toString cfg.programs.nano.package) (map toString cfg.environment.systemPackages);
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
          certificates = home != null && home.home.activation ? installNssDbCerts;
          tokens = home != null && home.home.activation ? installNssDbKeys;
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
        networkManager = cfg.networking.networkmanager.enable;
        bashCompletion = cfg.programs.bash.completion.enable;
        nixBashCompletions = builtins.elem (toString host.pkgs.nix-bash-completions) (
          map toString cfg.environment.systemPackages
        );
        mdnsFirewall = builtins.elem 5353 cfg.networking.firewall.allowedUDPPorts;
        sshPasswordAuthentication = cfg.services.openssh.settings.PasswordAuthentication;
        sudoWheelNeedsPassword = cfg.security.sudo.wheelNeedsPassword;
        transmission = cfg.services.transmission.enable;
        transmissionUnit = cfg.systemd.units ? "transmission.service";
        transmissionSetupUnit = cfg.systemd.units ? "transmission-setup.service";
        displayManager = cfg.services.displayManager.enable;
        git = cfg.programs.git.enable;
        certificates = map toString cfg.security.pki.certificateFiles;
      };
    };
in
lib.mapAttrs (_: snapshot) flake.nixosValidationConfigurations
