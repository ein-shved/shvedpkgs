let
  flake = builtins.getFlake (toString ../..);
  inputs = flake.inputs;
  lib = import ../../lib inputs;
  mkSystem =
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit lib; };
      modules = [
        ../../modules/home/user.nix
        {
          system.stateVersion = "26.05";
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "none";
            fsType = "tmpfs";
          };
          users.users.secondary = {
            isNormalUser = true;
            home = "/srv/secondary";
            description = "Independent account";
          };
        }
      ]
      ++ modules;
    };
  absent = mkSystem [ ];
  selected = mkSystem [ { user.name = "alice"; } ];
  customized =
    name:
    mkSystem [
      {
        user = {
          inherit name;
          humanName = "Display ${name}";
          home = "/srv/${name}";
          password = "test-only-${name}";
          mail = "${name}@example.invalid";
          domainName = "domain-${name}";
          extraGroups = [ "test-group" ];
        };
      }
    ];
  groups = [
    "wheel"
    "tty"
    "dialout"
    "keys"
    "audio"
    "adbusers"
    "docker"
    "input"
    "nixbld"
  ];
  sameGroups = a: b: lib.sort builtins.lessThan a == lib.sort builtins.lessThan b;
  account = selected.config.users.users.alice;
  mkHome =
    modules:
    mkSystem (
      [
        inputs.home-manager.nixosModules.default
        ../../modules/home/homedir.nix
      ]
      ++ modules
    );
  withHome =
    modules:
    mkHome (
      [
        {
          user.name = "alice";
          home.enable = true;
        }
      ]
      ++ modules
    );
  noHome = mkHome [ ];
  accountOnly = mkHome [ { user.name = "alice"; } ];
  explicitlyOff = mkHome [
    {
      user.name = "alice";
      home.enable = false;
    }
  ];
  active = withHome [ ];
  directOnly = withHome [
    { home-manager.users.alice.home.sessionVariables.DIRECT_ONLY = "direct"; }
  ];
  secondaryHome = mkHome [
    {
      home-manager.users.secondary.home.stateVersion = "26.05";
    }
  ];
  merged = withHome [
    {
      hm.home.sessionVariables.ALIAS = "alias";
      hm.home.sessionPath = lib.mkBefore [ "/before" ];
      hm.home.stateVersion = lib.mkDefault "24.11";
    }
    {
      home-manager.users.alice.home = {
        sessionVariables.DIRECT = "direct";
        sessionPath = lib.mkAfter [ "/after" ];
        stateVersion = "25.11";
      };
    }
  ];
  reversed = withHome [
    {
      hm.home.stateVersion = "25.11";
      home-manager.users.alice.home.stateVersion = lib.mkDefault "24.11";
    }
  ];
  forced = withHome [
    {
      hm = lib.mkForce { home.stateVersion = "25.11"; };
      home-manager.users.alice.home.stateVersion = "24.11";
    }
  ];
  directForce = withHome [
    {
      hm.home.stateVersion = "24.11";
      home-manager.users.alice.home.stateVersion = lib.mkForce "25.11";
    }
  ];
  refreshed = withHome [ { home.refresh-profile.enable = true; } ];
  refreshOff = withHome [ { home.refresh-profile.enable = false; } ];
  declarations = {
    attributes.hm.home.sessionVariables.DEFERRED = "applied";
    throwing.hm.home.sessionVariables.DEFERRED = throw "deferred nested value applied";
    login = { config, ... }: {
      hm.home.sessionVariables.DEFERRED = config.user.name;
    };
    aliasRead = { config, ... }: {
      hm.home.sessionVariables.DEFERRED = config.hm.home.username;
    };
    function.hm = { pkgs, ... }: {
      home.sessionVariables.DEFERRED = pkgs.stdenv.hostPlatform.system;
    };
    throwingFunction.hm = _: throw "deferred module body applied";
    imported.hm.imports = [
      ({ config, ... }: { home.sessionVariables.DEFERRED = config.home.username; })
    ];
    invalid = ./fixtures/primary-user-hm/alias-errors.nix;
  };
  inactiveDeclarations =
    modules:
    let
      host = mkHome (modules ++ builtins.attrValues declarations);
    in
    host.config.home-manager.users == { }
    && !(host.config.users.users ? "")
    && !(host.config.systemd.services ? home-manager-alice)
    && host.config.system.build.toplevel.drvPath != "";
  independentPrimary = mkHome [
    {
      user.name = "alice";
      home-manager.users.alice.home.stateVersion = "26.05";
      hm.home.sessionVariables.ALIAS = throw "declarations leaked into independent user";
    }
  ];
  independentSecondary = mkHome [
    {
      home-manager.users.secondary.home.stateVersion = "26.05";
      hm.home.sessionVariables.ALIAS = throw "declarations leaked into secondary user";
    }
  ];
  applied = name: (withHome [ declarations.${name} ]).config.hm;
  nestedConditions = withHome [
    {
      hm.home.sessionVariables = {
        TRUE = lib.mkIf true "selected";
        FALSE = lib.mkIf false (throw "false home branch evaluated");
      };
    }
  ];
  disabledRead = modules: (mkHome modules).config.hm;
  activation = host: host.config.home-manager.users.alice.home.activationPackage;
  defaultRoot = withHome [
    {
      hm = lib.mkDefault { home.stateVersion = "24.11"; };
      home-manager.users.alice.home.stateVersion = "25.11";
    }
  ];
  mkRepo =
    modules:
    (flake.extend {
      hosts.primaryUserHmFixture.modules = [
        {
          system.stateVersion = "26.05";
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "none";
            fsType = "tmpfs";
          };
          users.users.secondary = {
            isNormalUser = true;
            home = "/srv/secondary";
          };
        }
      ]
      ++ modules;
    }).nixosValidationConfigurations.primaryUserHmFixture;
  repoAbsent = mkRepo [ ];
  repoAccount = mkRepo [ { user.name = "alice"; } ];
  repoActive =
    modules:
    mkRepo (
      [
        {
          user.name = "alice";
          home.enable = true;
        }
      ]
      ++ modules
    );
  repoPlain = repoActive [ ];
  repoDisabled = mkRepo [
    {
      programs.pass.enable = lib.mkForce false;
      programs.firefox.enable = false;
      programs.chromium.enable = lib.mkForce false;
      environment.printing3d.enable = false;
    }
  ];
  repoGraphic = repoActive [
    {
      hardware.isGraphic = true;
      kl.enable = true;
    }
  ];
  repoPrinting = repoActive [ { environment.printing3d.enable = true; } ];
  repoNoPass = repoActive [ { programs.pass.enable = lib.mkForce false; } ];
  repoNoTransmission = repoActive [ { services.transmission.enable = false; } ];
  repoAccountTransmission = mkRepo [
    {
      user.name = "alice";
      services.transmission.enable = true;
    }
  ];
  repoUnmanaged = module: (mkRepo [ module ]).config;
  repoBrowser = repoUnmanaged { programs.firefox.enable = true; };
  repoChromium = repoUnmanaged { programs.chromium.enable = lib.mkForce true; };
  repoPass = repoUnmanaged { programs.pass.enable = true; };
  repoTrust = repoUnmanaged { kl.trust.enable = true; };
  repoGraphicOff = repoUnmanaged {
    hardware.isGraphic = true;
    kl.trust.enable = true;
    kl.nss.certificates.enable = true;
    kl.nss.tokens.enable = true;
  };
  repoPrintingOff = repoUnmanaged {
    user.name = "alice";
    environment.printing3d.enable = true;
  };
  repoDependencies =
    (mkRepo [
      {
        user.name = "alice";
        user.humanName = "Alice Example";
        services.klvpn.enable = true;
        services.cntlm-gss = {
          enable = true;
          proxy = [ "proxy.example.invalid:81" ];
        };
        hardware.isNas = true;
        kl.domain.enable = true;
      }
    ]).config;
  dormantModules = [
    ../../config/desktop/wpaperd
    ../../config/desktop/hyprland
    ../../config/desktop/hyprland/hyprland.nix
  ];
  repoDormant = mkRepo dormantModules;
  repoDormantActive = mkRepo (
    dormantModules
    ++ [
      {
        user.name = "alice";
        home.enable = true;
        hardware.isGraphic = true;
        programs.hyprland.enable = lib.mkForce true;
      }
    ]
  );
  dmConfig =
    modules:
    (mkRepo (
      modules
      ++ [
        {
          hardware.isGraphic = true;
          services.xserver.displayManager.lightdm.enable = lib.mkForce true;
        }
      ]
    )).config.services.xserver.displayManager.lightdm.greeters.gtk;
  dmRead = modules: (dmConfig modules).cursorTheme.name;
in
{
  accountChecks = {
    absent =
      !absent.options.user.name.isDefined
      && !(absent.config.users.users ? alice)
      && absent.config.users.users.secondary.home == "/srv/secondary"
      && absent.config.services.openssh.enable == false;
    noEnableOption = !(absent.options.user ? enable);
    defaults =
      account.name == "alice"
      && account.isNormalUser
      && account.createHome
      && account.home == "/home/alice"
      && account.description == "alice"
      && account.password == null
      && selected.config.user.domainName == ""
      && sameGroups account.extraGroups groups;
    surname =
      (mkSystem [
        {
          user.name = "login";
          user.humanName = "Alice Cooper";
        }
      ]).config.user.domainName == "cooper";
    factory =
      (mkSystem [
        {
          user.name = "login";
          user.domainNameMaker = name: "custom-${name}";
        }
      ]).config.user.domainName == "custom-login";
    overrides =
      builtins.all
        (
          name:
          let
            cfg = (customized name).config;
            u = cfg.users.users.${name};
          in
          u.name == name
          && u.description == "Display ${name}"
          && u.home == "/srv/${name}"
          && u.password == "test-only-${name}"
          && cfg.user.mail == "${name}@example.invalid"
          && cfg.user.domainName == "domain-${name}"
          && sameGroups u.extraGroups (groups ++ [ "test-group" ])
          && cfg.users.users.secondary.home == "/srv/secondary"
        )
        [
          "alice"
          "bob"
        ];
  };
  missing = {
    inherit (absent.config.user)
      name
      humanName
      home
      domainName
      ;
  };
  homeChecks = {
    defaultOff =
      !noHome.config.home.enable
      && noHome.config.home-manager.users == { }
      && !noHome.config.home-manager.useGlobalPkgs
      && !(noHome.config.users.users ? alice);
    accountOnly =
      accountOnly.config.users.users.alice.isNormalUser
      && accountOnly.config.home-manager.users == { }
      && !accountOnly.config.home-manager.useGlobalPkgs;
    explicitOff = explicitlyOff.config.home-manager.users == { };
    active =
      builtins.attrNames active.config.home-manager.users == [ "alice" ]
      && active.config.hm.home.username == "alice"
      && active.config.hm.home.homeDirectory == "/home/alice"
      && active.config.hm.home.stateVersion == "26.05"
      && active.config.home-manager.useGlobalPkgs;
    directOnly =
      directOnly.config.hm.home.sessionVariables.DIRECT_ONLY == "direct"
      && directOnly.config.hm.home.activationPackage.drvPath != "";
    secondary =
      builtins.attrNames secondaryHome.config.home-manager.users == [ "secondary" ]
      && secondaryHome.config.home-manager.users.secondary.home.homeDirectory == "/srv/secondary"
      && !secondaryHome.config.home-manager.useGlobalPkgs
      && secondaryHome.config.home-manager.users.secondary.home.activationPackage.drvPath != "";
    deferredType =
      active.options.hm.type.name == "deferredModule" && noHome.options.hm.type.name == "deferredModule";
    inactiveNoLogin = inactiveDeclarations [ ];
    inactiveAccountOnly = inactiveDeclarations [ { user.name = "alice"; } ];
    inactiveExplicitOff = inactiveDeclarations [
      {
        user.name = "alice";
        home.enable = false;
      }
    ];
    independentDeclarations =
      !(independentPrimary.config.home-manager.users.alice.home.sessionVariables ? ALIAS)
      && !(independentSecondary.config.home-manager.users.secondary.home.sessionVariables ? ALIAS)
      && !independentPrimary.config.home-manager.useGlobalPkgs
      && independentPrimary.config.home-manager.users.alice.home.activationPackage.drvPath != ""
      && independentSecondary.config.system.build.toplevel.drvPath != "";
    appliedDeclarations =
      (applied "attributes").home.sessionVariables.DEFERRED == "applied"
      && (applied "login").home.sessionVariables.DEFERRED == "alice"
      && (applied "aliasRead").home.sessionVariables.DEFERRED == "alice"
      && (applied "function").home.sessionVariables.DEFERRED == "x86_64-linux"
      && (applied "imported").home.sessionVariables.DEFERRED == "alice"
      && (applied "imported").home.activationPackage.drvPath != "";
    nestedConditions =
      nestedConditions.config.hm.home.sessionVariables.TRUE == "selected"
      && nestedConditions.config.hm.home.sessionVariables.FALSE == null
      && nestedConditions.config.hm.home.activationPackage.drvPath != "";
    inactiveRefresh =
      builtins.all
        (
          modules:
          let
            host = mkHome (modules ++ [ { home.refresh-profile.enable = true; } ]);
          in
          host.config.home-manager.users == { } && host.config.system.build.toplevel.drvPath != ""
        )
        [
          [ ]
          [ { user.name = "alice"; } ]
        ];
    library = (lib.hm.dag.entryAfter [ "step" ] "value").data == "value";
    merge =
      merged.config.hm.home.sessionVariables.ALIAS == "alias"
      && merged.config.hm.home.sessionVariables.DIRECT == "direct"
      &&
        merged.config.hm.home.sessionVariables
        == merged.config.home-manager.users.alice.home.sessionVariables;
    priorities =
      merged.config.hm.home.stateVersion == "25.11"
      && reversed.config.hm.home.stateVersion == "25.11"
      && forced.config.hm.home.stateVersion == "25.11"
      && directForce.config.hm.home.stateVersion == "25.11"
      && defaultRoot.config.hm.home.stateVersion == "25.11";
    ordering =
      merged.config.hm.home.sessionPath == [
        "/before"
        "/after"
      ];
    activation = (activation merged).drvPath != "";
    refreshDefault =
      !(active.config.hm.home.activation ? preInstallPackages)
      && !(refreshOff.config.hm.home.activation ? preInstallPackages);
    refreshEnabled =
      refreshed.config.hm.home.activation.preInstallPackages.before == [ "installPackages" ]
      && lib.hasInfix "manifest.json" refreshed.config.hm.home.activation.preInstallPackages.data
      && lib.hasInfix "nix profile add" refreshed.config.hm.home.activation.preInstallPackages.data
      && (activation refreshed).drvPath != "";
  };
  homeErrors = {
    missingLogin = (mkHome [ { home.enable = true; } ]).config.system.build.toplevel.drvPath;
    conflict =
      (withHome [
        ./fixtures/primary-user-hm/alias-errors.nix
        ./fixtures/primary-user-hm/direct-conflict.nix
      ]).config.hm.home.stateVersion;
    readNoLogin = disabledRead [ ];
    readAccountOnly = disabledRead [ { user.name = "alice"; } ];
    readSecondary = secondaryHome.config.hm;
    readIndependentPrimary = independentPrimary.config.hm;
    nestedThrow = (applied "throwing").home.activationPackage.drvPath;
    moduleThrow = (applied "throwingFunction").home.activationPackage.drvPath;
    invalidValue = (applied "invalid").home.activationPackage.drvPath;
  };
  refreshActivation = {
    enabled = (activation refreshed).drvPath;
    disabled = (activation active).drvPath;
  };
  transmissionChecks = {
    noLogin =
      !repoAbsent.config.services.transmission.enable
      && repoAbsent.config.system.build.toplevel.drvPath != "";
    accountOnlyDefault =
      !repoAccount.config.services.transmission.enable
      && repoAccount.config.system.build.toplevel.drvPath != "";
    managed =
      repoPlain.config.services.transmission.enable
      && builtins.elem "home-manager-alice.service" repoPlain.config.systemd.services.transmission.after
      && repoPlain.config.hm.home.activation ? transmission-daemon;
    disabled =
      !repoNoTransmission.config.services.transmission.enable
      && !(repoNoTransmission.config.systemd.units ? "transmission.service")
      && !(repoNoTransmission.config.hm.home.activation ? transmission-daemon)
      && repoNoTransmission.config.system.build.toplevel.drvPath != "";
    accountOnlySelected =
      let
        cfg = repoAccountTransmission.config;
      in
      cfg.services.transmission.user == "alice"
      && cfg.services.transmission.home == "/home/alice"
      && cfg.home-manager.users == { }
      && !(builtins.elem "home-manager-alice.service" cfg.systemd.services.transmission.after)
      && lib.hasInfix "/home/alice/.config/transmission-daemon" cfg.systemd.services.transmission-setup.script
      && cfg.system.build.toplevel.drvPath != "";
  };
  transmissionMissingLogin =
    (repoUnmanaged { services.transmission.enable = true; }).system.build.toplevel.drvPath;
  consumerChecks = {
    absent =
      repoAbsent.config.home-manager.users == { }
      && !repoAbsent.options.user.name.isDefined
      && !repoAbsent.config.services.transmission.enable
      && repoAbsent.config.programs.pass.enable
      && repoAbsent.config.system.build.toplevel.drvPath != "";
    accountOnly =
      repoAccount.config.home-manager.users == { }
      && repoAccount.config.users.users.alice.isNormalUser
      && repoAccount.config.system.build.toplevel.drvPath != "";
    disabled =
      repoDisabled.config.home-manager.users == { }
      && repoDisabled.config.system.build.toplevel.drvPath != "";
    independent =
      repoAbsent.config.services.openssh.enable
      && repoAbsent.config.programs.ssh.startAgent
      && repoAbsent.config.security.pki.certificateFiles == [ ]
      && repoTrust.security.pki.certificateFiles != [ ]
      && !(builtins.elem "alice" repoAbsent.config.nix.settings.trusted-users)
      && repoAbsent.config.environment.systemPackages != [ ]
      && repoAbsent.config.users.users.secondary.home == "/srv/secondary";
    managed =
      repoPlain.config.hm.programs.git.enable
      && repoPlain.config.hm.programs.ssh.enable
      && repoPlain.config.hm.programs.kitty.enable
      && repoPlain.config.hm.home.file ? ".toprc"
      && repoPlain.config.hm.home.activation ? installPassGpgKey
      && repoPlain.config.hm.home.activation ? transmission-daemon
      && !(repoPlain.config.hm.home.activation ? mergeMzNssDb);
    graphical =
      repoGraphic.config.hm.home.activation ? mergeMzNssDb
      && repoGraphic.config.hm.home.activation ? installNssDbCerts
      && repoGraphic.config.hm.home.activation ? installNssDbKeys
      && repoGraphic.config.hm.programs.niri.settings != { }
      && repoGraphic.config.hm.programs.waybar.enable
      && repoGraphic.config.hm.programs.swaylock.enable
      && repoGraphic.config.hm.services.awww.enable
      && repoGraphic.config.hm.programs.anyrun.enable
      && repoGraphic.config.hm.home.activationPackage.drvPath != "";
    printing =
      repoPrinting.config.hm.home.activation ? prusaConfig
      && repoPrinting.config.services.gitwatch.modeling3d.user == "alice"
      && repoPrinting.config.services.gitwatch.modeling3d.path == "/home/alice/Projects/3D";
    explicitDisable =
      !(repoNoPass.config.hm.home.activation ? installPassGpgKey)
      && !(repoNoTransmission.config.hm.home.activation ? transmission-daemon)
      && !repoNoTransmission.config.services.transmission.enable;
    dormant = repoDormant.config.home-manager.users == { };
    dormantEnabled =
      repoDormantActive.config.hm.services.wpaperd.enable
      && repoDormantActive.config.hm.wayland.windowManager.hyprland.enable;
    selectedDormant =
      (repoDormant.extendModules {
        modules = [
          {
            hardware.isGraphic = true;
            programs.hyprland.enable = lib.mkForce true;
          }
        ];
      }).config.home-manager.users == { };
    unmanagedDeclarations =
      repoBrowser.programs.firefox.enable
      && repoBrowser.home-manager.users == { }
      && repoChromium.programs.chromium.enable
      && repoChromium.home-manager.users == { }
      && repoPass.programs.pass.enable
      && repoPass.home-manager.users == { }
      && repoGraphicOff.programs.niri.enable
      && repoGraphicOff.home-manager.users == { }
      && repoGraphicOff.security.pki.certificateFiles != [ ]
      && repoGraphicOff.system.build.toplevel.drvPath != "";
    passSystem =
      repoPass.programs.gnupg.agent.enable
      && builtins.elem (toString (repoAbsent.pkgs.pass.withExtensions (exts: [ exts.pass-otp ]))) (
        map toString repoPass.environment.systemPackages
      );
    printingAccountOnly =
      repoPrintingOff.home-manager.users == { }
      && repoPrintingOff.services.gitwatch.modeling3d.user == "alice"
      && repoPrintingOff.services.gitwatch.modeling3d.path == "/home/alice/Projects/3D"
      && builtins.elem (toString repoAccount.pkgs.prusa-slicer) (
        map toString repoPrintingOff.environment.systemPackages
      )
      && repoPrintingOff.system.build.toplevel.drvPath != "";
    suppliedDependencies =
      lib.hasInfix "\"alice\"" repoDependencies.security.polkit.extraConfig
      && repoDependencies.systemd.services.cntlm-gss.serviceConfig.User == "alice"
      && repoDependencies.services.navidrome.settings.MusicFolder == "/home/alice/Downloads/Music"
      && repoDependencies.user.mail == "alice.example@kaspersky.com"
      && repoDependencies.kl.domain.hostname == "example";
    dmRead =
      dmRead [
        {
          user.name = "alice";
          home.enable = true;
        }
      ] == "Bibata-Modern-Classic";
    dmTheme =
      let
        gtk = dmConfig [
          {
            user.name = "alice";
            home.enable = true;
          }
        ];
      in
      gtk.theme.name != "" && gtk.iconTheme.name != "";
    accountMetadata =
      (repoActive [
        {
          user.humanName = "Alice Example";
          user.mail = "alice@example.invalid";
        }
      ]).config.hm.programs.git.settings.user == {
        name = "Alice Example";
        email = "alice@example.invalid";
      };
  };
  consumerErrors = {
    dmAccountOnly = dmRead [ { user.name = "alice"; } ];
    dmTheme = (dmConfig [ ]).theme.name;
    printing =
      (repoUnmanaged { environment.printing3d.enable = true; }).services.gitwatch.modeling3d.user;
    vpn = (mkRepo [ { services.klvpn.enable = true; } ]).config.security.polkit.extraConfig;
    media = (mkRepo [ { hardware.isNas = true; } ]).config.services.navidrome.settings.MusicFolder;
    dmRead =
      (mkHome [
        ../../modules/hardware/hosts
        ../../modules/hardware/monitors
        ../../config/desktop/dm
        {
          hardware.isGraphic = true;
          services.xserver.displayManager.lightdm.enable = true;
        }
      ]).config.services.xserver.displayManager.lightdm.greeters.gtk.cursorTheme.name;
    cntlm =
      (mkRepo [
        {
          services.cntlm-gss.enable = true;
          services.cntlm-gss.proxy = [ "proxy.example.invalid:81" ];
        }
      ]).config.systemd.services.cntlm-gss.serviceConfig.User;
    kl = (mkRepo [ { kl.enable = true; } ]).config.user.mail;
    domain = (mkRepo [ { kl.domain.enable = true; } ]).config.kl.domain.hostname;
  };
}
