let
  flake = builtins.getFlake (toString ../..);
  inputs = flake.inputs;
  lib = import ../../lib inputs;
  mkSystem =
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit lib;
        flake-inputs = inputs;
        pkgsUnstable = import inputs.unstable { system = "x86_64-linux"; };
      };
      modules = [
        {
          system.stateVersion = "26.05";
          boot.loader.grub.enable = false;
          fileSystems."/" = lib.mkDefault {
            device = "none";
            fsType = "tmpfs";
          };
        }
      ]
      ++ modules;
    };
  hardwareModules = [
    ../../modules/hardware/power
    ../../modules/os-specific/linux/keyutils
    ../../modules/hardware/development/programmers/avr
    ../../modules/hardware/development/programmers/stm32
    ../../modules/hardware/hdparm
    ../../modules/hardware/hosts
  ];
  hardware = extra: (mkSystem (hardwareModules ++ extra)).config;
  baseline = (mkSystem [ ]).config;
  offSettings = {
    hardware.power.wakeOnPowerButtonOnly.enable = false;
    services.cifsKeyutils.enable = false;
    hardware.programmers.avr.enable = false;
    hardware.programmers.stm32.enable = false;
  };
  onSettings = {
    hardware.power.wakeOnPowerButtonOnly.enable = true;
    services.cifsKeyutils.enable = true;
    hardware.programmers.avr.enable = true;
    hardware.programmers.stm32.enable = true;
  };
  hwDefault = hardware [ ];
  hwOff = hardware [ offSettings ];
  hwOn = hardware [ onSettings ];
  policy =
    settings:
    hardware (
      klModules
      ++ [
        ../../config/default.nix
        settings
      ]
    );
  dev = policy { hardware.isDevelopment = true; };
  nonDev = policy { };
  nonDevOff = policy offSettings;
  devOff = policy (
    lib.recursiveUpdate offSettings {
      hardware.isDevelopment = true;
      services.logind.settings.Login.HandlePowerKey = "ignore";
    }
  );
  nonDevOn = policy onSettings;
  packages = cfg: map (p: p.outPath) cfg.environment.systemPackages;
  inactiveHardware =
    cfg:
    !(cfg.systemd.services ? wakeOnPowerButtonOnly)
    && !(cfg.system.activationScripts ? symlink-requestkey)
    && !(cfg.environment.etc ? "request-key.conf")
    && cfg.services.udev.extraRules == baseline.services.udev.extraRules
    && packages cfg == packages baseline
    && cfg.services.logind.settings == baseline.services.logind.settings;
  # Package values come from the evaluated system, rather than config.
  hwPkgs = (mkSystem hardwareModules).pkgs;
  standby = hardware [
    {
      hardware.drives = {
        "/dev/disabled".standby.enable = false;
        "/dev/sda".standby = {
          enable = true;
          timeout = 12;
        };
      };
    }
  ];
  disabledDrive = hardware [ { hardware.drives."/dev/disabled" = { }; } ];
  standbyUnits =
    cfg: lib.filter (lib.hasPrefix "hard-drive-standby-") (builtins.attrNames cfg.systemd.services);
  standbyTimers =
    cfg: lib.filter (lib.hasPrefix "hard-drive-standby-") (builtins.attrNames cfg.systemd.timers);
  klModules = [
    inputs.home-manager.nixosModules.default
    ../../modules/home/user.nix
    ../../modules/home/homedir.nix
    ../../modules/employment/kl
    ../../modules/security/ca.nix
  ];
  mkKl =
    extra:
    mkSystem (
      hardwareModules
      ++ klModules
      ++ [
        ../../pkgs
        { nixpkgs.config.allowUnfree = true; }
      ]
      ++ extra
    );
  klActive =
    settings:
    (mkKl [
      {
        user.name = "alice";
        home.enable = true;
      }
      settings
    ]).config;
  klDefault = klActive { };
  klOff = klActive {
    kl.trust.enable = false;
    kl.nss.certificates.enable = false;
    kl.nss.tokens.enable = false;
  };
  klTrust = klActive { kl.trust.enable = true; };
  klCerts = klActive { kl.nss.certificates.enable = true; };
  klTokens = klActive { kl.nss.tokens.enable = true; };
  klPolicy =
    settings:
    (mkKl [
      ../../config/default.nix
      settings
    ]).config;
  employment = klPolicy { kl.enable = true; };
  graphicEmployment = klPolicy {
    kl.enable = true;
    hardware.isGraphic = true;
    user.name = "alice";
    home.enable = true;
  };
  graphicOnly = klPolicy { hardware.isGraphic = true; };
  klPolicyOff = klPolicy {
    kl.enable = true;
    hardware.isGraphic = true;
    kl.trust.enable = false;
    kl.nss.certificates.enable = false;
    kl.nss.tokens.enable = false;
  };
  inactiveNss =
    withAccount:
    (mkKl [
      {
        user = lib.mkIf withAccount { name = "alice"; };
        kl.trust.enable = true;
        kl.nss.certificates.enable = true;
        kl.nss.tokens.enable = true;
        nixpkgs.overlays = [
          (_: _: {
            nss = throw "unused NSS dependency forced";
            pcsc-safenet = throw "unused token dependency forced";
            rtpkcs11ecp = throw "unused token dependency forced";
          })
        ];
      }
    ]).config;
  nssActivation = cfg: cfg.hm.home.activation;
  noNss = cfg: !(nssActivation cfg ? installNssDbCerts) && !(nssActivation cfg ? installNssDbKeys);
  noTrust =
    cfg:
    cfg.security.pki.certificateFiles == [ ] && !(cfg.environment.sessionVariables ? CURL_CA_BUNDLE);
  serviceModules = [
    ../../modules/services/gerrit
    ../../modules/services/vps
    ../../modules/applications/misc/gaming
    ../../modules/hardware/hosts
    ../../pkgs
    { nixpkgs.config.allowUnfree = true; }
  ];
  services = extra: (mkSystem (serviceModules ++ extra)).config;
  serviceDefault = services [ ];
  serviceOff = services [
    {
      services.gerrit.enable = false;
      environment.gaming.enable = false;
    }
  ];
  gerritInputs = {
    services.gerrit.serverId = "test-only-server-identity";
    services.vps.domain = "gerrit.example.invalid";
    services.gerrit.extraConfigFiles = [ "/run/test-only/gerrit-secret" ];
  };
  gerritOn = services [
    gerritInputs
    { services.gerrit.enable = true; }
  ];
  vps = services [
    ../../config/services
    { hardware.isVps = true; }
    gerritInputs
  ];
  vpsOff = services [
    ../../config/services
    {
      hardware.isVps = true;
      services.gerrit.enable = false;
    }
  ];
  gaming = services [ { environment.gaming.enable = true; } ];
  gamingNoSteam = services [
    {
      environment.gaming.enable = true;
      programs.steam.enable = false;
    }
  ];
  independentSteam = services [ { programs.steam.enable = true; } ];
  upstreamSteam =
    (mkSystem [
      {
        nixpkgs.config.allowUnfree = true;
        programs.steam.enable = true;
      }
    ]).config;
  steamSettings = cfg: {
    inherit (cfg.programs.steam)
      remotePlay
      dedicatedServer
      localNetworkGameTransfers
      extest
      ;
  };
  firewall = cfg: {
    inherit (cfg.networking.firewall)
      allowedTCPPorts
      allowedUDPPorts
      allowedTCPPortRanges
      allowedUDPPortRanges
      ;
  };
  noGerrit =
    cfg:
    !cfg.services.gerrit.enable
    && cfg.services.gerrit.settings == { }
    && cfg.services.gerrit.plugins == [ ]
    && !(cfg.systemd.services ? gerrit)
    && !(cfg.systemd.sockets ? gerrit)
    && !(builtins.elem 29418 cfg.networking.firewall.allowedTCPPorts);
  collectionSupport = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-generators.nixosModules.all-formats
  ];
  collectionBase = mkSystem collectionSupport;
  mkCollection = extra: mkSystem (collectionSupport ++ [ ../../modules/nixos.nix ] ++ extra);
  collectionDefault = mkCollection [ ];
  collectionOff = mkCollection [
    {
      home.enable = false;
      environment.gaming.enable = false;
      environment.printing3d.enable = false;
      programs.translate-shell.enable = false;
      programs.pass.enable = false;
      kl.enable = false;
      kl.domain.enable = false;
      kl.remote.enable = false;
      kl.trust.enable = false;
      kl.nss.certificates.enable = false;
      kl.nss.tokens.enable = false;
      services.cifsKeyutils.enable = false;
      services.gerrit.enable = false;
      services.nginx.enable = false;
      services.cntlm-gss.enable = false;
      services.klvpn.enable = false;
      hardware.power.wakeOnPowerButtonOnly.enable = false;
      hardware.programmers.avr.enable = false;
      hardware.programmers.stm32.enable = false;
    }
  ];
  effectSnapshot = cfg: {
    packages = packages cfg;
    accounts = cfg.users.users;
    homes = builtins.attrNames cfg.home-manager.users;
    certificates = map toString cfg.security.pki.certificateFiles;
    sessionVariables = cfg.environment.sessionVariables;
    activation = cfg.system.activationScripts;
    units = lib.mapAttrs (_: unit: toString unit.unit) cfg.systemd.units;
    etc = lib.mapAttrs (_: entry: toString entry.source) cfg.environment.etc;
    firewall = firewall cfg;
    udev = cfg.services.udev.extraRules;
    kernelModules = cfg.boot.kernelModules;
    logind = cfg.services.logind.settings;
    nginxHosts = builtins.attrNames cfg.services.nginx.virtualHosts;
  };
  collectionIndependent = mkCollection [ { services.openssh.enable = true; } ];
  collectionAvr = mkCollection [ { hardware.programmers.avr.enable = true; } ];
  browser =
    extra:
    (mkCollection (
      [
        {
          user.name = "alice";
          home.enable = true;
        }
      ]
      ++ extra
    )).config;
  browserOff = browser [ ];
  firefox = browser [ { programs.firefox.enable = true; } ];
  chromium = browser [ { programs.chromium.enable = true; } ];
  browserExplicitOff = browser [
    {
      programs.firefox.enable = false;
      programs.chromium.enable = false;
    }
  ];
  luks =
    (mkCollection [
      {
        boot.initrd.luks.devices.test.device = "/dev/test-only-luks";
      }
    ]).config;
  packageNames = cfg: map lib.getName cfg.environment.systemPackages;
  formatPolicy = mkCollection [ ../../config/hardware/bootable ];
  evalFormat =
    host: name:
    (host.extendModules {
      modules = [
        "${inputs.nixos-generators}/format-module.nix"
        host.config.formatConfigs.${name}
      ];
    }).config;
  formatSnapshot = cfg: {
    kernel = cfg.boot.kernelPackages.kernel.drvPath;
    filesystems = cfg.boot.supportedFilesystems;
    installerEdition = cfg.isoImage.edition or null;
    format = cfg.formatAttr;
  };
  comparedFormats = [
    "iso"
    "qcow"
    "raw"
  ];
in
{
  hardware = {
    defaultOff = inactiveHardware hwDefault;
    explicitOff = inactiveHardware hwOff;
    enabledPower = lib.hasInfix "/proc/acpi/wakeup" hwOn.systemd.services.wakeOnPowerButtonOnly.script;
    enabledKeyutils =
      lib.hasInfix "/sbin/request-key" hwOn.system.activationScripts.symlink-requestkey
      && lib.hasInfix "cifs.upcall" hwOn.environment.etc."request-key.conf".text
      && builtins.elem hwPkgs.keyutils.outPath (packages hwOn)
      && builtins.elem hwPkgs.cifs-utils.outPath (packages hwOn);
    enabledAvr = lib.hasInfix "05dc" hwOn.services.udev.extraRules;
    enabledStm32 =
      lib.hasInfix "stlinkv3" hwOn.services.udev.extraRules
      && builtins.elem hwPkgs.stlink.outPath (packages hwOn)
      && builtins.elem hwPkgs.st-gpio.outPath (packages hwOn);
    independentPackage = hwPkgs.st-gpio.drvPath != "";
    independentFeature =
      lib.hasInfix "05dc"
        (hardware [ { hardware.programmers.avr.enable = true; } ]).services.udev.extraRules
      && !(hwOff.systemd.services ? wakeOnPowerButtonOnly);
    developmentPolicy =
      dev.hardware.power.wakeOnPowerButtonOnly.enable
      && dev.services.cifsKeyutils.enable
      && dev.hardware.programmers.avr.enable
      && dev.hardware.programmers.stm32.enable
      && dev.services.logind.settings.Login.HandlePowerKey == "suspend"
      && dev.services.logind.settings.Login.HandleLidSwitch == "ignore";
    nonDevelopmentPolicy =
      !nonDev.hardware.power.wakeOnPowerButtonOnly.enable
      && nonDev.services.cifsKeyutils.enable
      && !nonDev.hardware.programmers.avr.enable
      && !nonDev.hardware.programmers.stm32.enable
      && nonDev.services.logind.settings == baseline.services.logind.settings;
    policyOverrides =
      !(devOff.systemd.services ? wakeOnPowerButtonOnly)
      && !(devOff.environment.etc ? "request-key.conf")
      && !(lib.hasInfix "05dc" devOff.services.udev.extraRules)
      && !(lib.hasInfix "stlinkv3" devOff.services.udev.extraRules)
      && devOff.services.logind.settings.Login.HandlePowerKey == "ignore"
      && nonDevOn.hardware.programmers.stm32.enable;
    keyutilsPolicy =
      lib.all
        (
          cfg:
          cfg.services.cifsKeyutils.enable
          && lib.hasInfix "/sbin/request-key" cfg.system.activationScripts.symlink-requestkey
          && lib.hasInfix "cifs.upcall" cfg.environment.etc."request-key.conf".text
          && builtins.elem hwPkgs.keyutils.outPath (packages cfg)
          && builtins.elem hwPkgs.cifs-utils.outPath (packages cfg)
        )
        [
          dev
          nonDev
        ];
    keyutilsPolicyOverrides =
      lib.all
        (
          cfg:
          !cfg.services.cifsKeyutils.enable
          && !(cfg.system.activationScripts ? symlink-requestkey)
          && !(cfg.environment.etc ? "request-key.conf")
        )
        [
          devOff
          nonDevOff
        ];
    emptyDrives = standbyUnits hwDefault == [ ] && standbyTimers hwDefault == [ ];
    disabledDrives = standbyUnits disabledDrive == [ ] && standbyTimers disabledDrive == [ ];
    mixedDrives =
      standbyUnits standby == [ "hard-drive-standby-dev-sda" ]
      && standbyTimers standby == [ "hard-drive-standby-dev-sda" ]
      && lib.hasInfix "hdparm -S 12 /dev/sda" standby.systemd.services.hard-drive-standby-dev-sda.script
      && standby.systemd.timers.hard-drive-standby-dev-sda.timerConfig.OnBootSec == 60;
  };
  kl = {
    defaultOff = noTrust klDefault && noNss klDefault;
    explicitOff = noTrust klOff && noNss klOff;
    trustOnly =
      klTrust.security.pki.certificateFiles != [ ]
      && klTrust.environment.sessionVariables.CURL_CA_BUNDLE == "/etc/ssl/certs/ca-bundle.crt"
      && noNss klTrust;
    certificatesOnly =
      noTrust klCerts
      && lib.hasInfix "certutil" (nssActivation klCerts).installNssDbCerts.data
      && !(nssActivation klCerts ? installNssDbKeys);
    tokensOnly =
      noTrust klTokens
      && lib.hasInfix "libeToken.so" (nssActivation klTokens).installNssDbKeys.data
      && lib.hasInfix "librtpkcs11ecp.so" (nssActivation klTokens).installNssDbKeys.data
      && !(nssActivation klTokens ? installNssDbCerts);
    employmentPolicy =
      employment.kl.trust.enable
      && !employment.kl.nss.certificates.enable
      && !employment.kl.nss.tokens.enable;
    graphicEmploymentPolicy =
      graphicEmployment.kl.trust.enable
      && nssActivation graphicEmployment ? installNssDbCerts
      && nssActivation graphicEmployment ? installNssDbKeys
      && graphicEmployment.hm.home.activationPackage.drvPath != "";
    graphicOnlyPolicy =
      noTrust graphicOnly && !graphicOnly.kl.nss.certificates.enable && !graphicOnly.kl.nss.tokens.enable;
    overridePolicy =
      noTrust klPolicyOff && !klPolicyOff.kl.nss.certificates.enable && !klPolicyOff.kl.nss.tokens.enable;
    inactiveNoLogin =
      (inactiveNss false).home-manager.users == { }
      && (inactiveNss false).security.pki.certificateFiles != [ ]
      && (inactiveNss false).system.build.toplevel.drvPath != "";
    inactiveAccountOnly =
      (inactiveNss true).home-manager.users == { }
      && (inactiveNss true).security.pki.certificateFiles != [ ]
      && (inactiveNss true).system.build.toplevel.drvPath != "";
  };
  services = {
    defaultOff =
      noGerrit serviceDefault
      && steamSettings serviceDefault == steamSettings baseline
      && firewall serviceDefault == firewall baseline
      && serviceDefault.boot.kernelModules == baseline.boot.kernelModules
      && packages serviceDefault == packages baseline;
    explicitOff =
      noGerrit serviceOff
      && steamSettings serviceOff == steamSettings baseline
      && firewall serviceOff == firewall baseline;
    gerritEnabled =
      gerritOn.services.gerrit.enable
      && gerritOn.services.gerrit.settings.auth.type == "oauth"
      && gerritOn.services.gerrit.settings.gerrit.canonicalWebUrl == "https://gerrit.example.invalid"
      && gerritOn.services.gerrit.settings.gerrit.serverId == "test-only-server-identity"
      && builtins.length gerritOn.services.gerrit.plugins == 2
      && lib.hasInfix "CREDENTIALS_DIRECTORY/1-gerrit-secret" gerritOn.systemd.services.gerrit.preStart
      &&
        gerritOn.systemd.services.gerrit.serviceConfig.LoadCredential
        == [ "1-gerrit-secret:/run/test-only/gerrit-secret" ]
      && builtins.elem 29418 gerritOn.networking.firewall.allowedTCPPorts
      && gerritOn.systemd.units."gerrit.service".unit != null;
    vpsPolicy =
      vps.services.gerrit.enable && noGerrit vpsOff && vpsOff.system.build.toplevel.drvPath != "";
    gamingEnabled =
      gaming.programs.steam.enable
      && builtins.elem "hid-playstation" gaming.boot.kernelModules
      && gaming.programs.steam.extest.enable
      && gaming.programs.steam.remotePlay.openFirewall
      && gaming.programs.steam.dedicatedServer.openFirewall
      && gaming.programs.steam.localNetworkGameTransfers.openFirewall
      && builtins.elem 27036 gaming.networking.firewall.allowedTCPPorts;
    steamDisabled =
      !gamingNoSteam.programs.steam.enable
      && builtins.elem "hid-playstation" gamingNoSteam.boot.kernelModules
      && steamSettings gamingNoSteam == steamSettings baseline
      && firewall gamingNoSteam == firewall baseline;
    independentSteam =
      independentSteam.programs.steam.enable
      && !(builtins.elem "hid-playstation" independentSteam.boot.kernelModules)
      && steamSettings independentSteam == steamSettings upstreamSteam
      && firewall independentSteam == firewall upstreamSteam;
  };
  collection = {
    defaultEffects = effectSnapshot collectionDefault.config == effectSnapshot collectionBase.config;
    explicitOffEffects = effectSnapshot collectionOff.config == effectSnapshot collectionBase.config;
    defaultToplevel = collectionDefault.config.system.build.toplevel.drvPath != "";
    explicitOffToplevel = collectionOff.config.system.build.toplevel.drvPath != "";
    noPrimarySelection =
      !collectionDefault.options.user.name.isDefined
      && collectionDefault.config.home-manager.users == { };
    independentService =
      collectionIndependent.config.services.openssh.enable
      && collectionIndependent.config.systemd.units."sshd.service".unit != null
      && !collectionIndependent.config.services.gerrit.enable
      && collectionIndependent.config.system.build.toplevel.drvPath != "";
    independentProgrammer =
      lib.hasInfix "05dc" collectionAvr.config.services.udev.extraRules
      && !collectionAvr.config.hardware.programmers.stm32.enable
      && collectionAvr.config.system.build.toplevel.drvPath != "";
    browserDefaultOff =
      !(browserOff.hm.home.activation ? mergeMzNssDb)
      && !(browserExplicitOff.hm.home.activation ? mergeMzNssDb);
    browserSelections =
      lib.hasInfix "mozilla_merge_nss" firefox.hm.home.activation.mergeMzNssDb.data
      && lib.hasInfix "libnssckbi.so" firefox.hm.home.activation.globalTrustedCerts.data
      && chromium.hm.home.activation ? mergeMzNssDb;
    luksDefaultOff =
      !(builtins.elem "diskAddKey" (packageNames collectionDefault.config))
      && !(builtins.elem "diskRemoveKey" (packageNames collectionDefault.config));
    luksSelected =
      builtins.elem "diskAddKey" (packageNames luks)
      && builtins.elem "diskRemoveKey" (packageNames luks)
      && luks.system.build.toplevel.drvPath != "";
  };
  formats = {
    sameAvailableFormats =
      builtins.attrNames collectionDefault.config.formatConfigs
      == builtins.attrNames collectionBase.config.formatConfigs
      &&
        builtins.attrNames formatPolicy.config.formatConfigs
        == builtins.attrNames collectionBase.config.formatConfigs;
    reusableMatchesUpstream = lib.all (
      name:
      formatSnapshot (evalFormat collectionDefault name)
      == formatSnapshot (evalFormat collectionBase name)
    ) comparedFormats;
    policyApplied = lib.all (
      name:
      let
        cfg = evalFormat formatPolicy name;
      in
      cfg.boot.kernelPackages.kernel.drvPath == formatPolicy.pkgs.linuxPackages_latest.kernel.drvPath
      &&
        cfg.boot.supportedFilesystems == lib.genAttrs [
          "btrfs"
          "reiserfs"
          "vfat"
          "f2fs"
          "xfs"
          "ntfs"
          "cifs"
        ] (_: true)
      && cfg.isoImage.edition == "minimal"
    ) comparedFormats;
    policyDiffers = lib.all (
      name:
      formatSnapshot (evalFormat formatPolicy name) != formatSnapshot (evalFormat collectionBase name)
    ) comparedFormats;
  };
  formatSettings = lib.genAttrs comparedFormats (name: formatSnapshot (evalFormat formatPolicy name));
  hosts =
    let
      snapshots = import ./primary-user-hm-hosts.nix;
    in
    {
      hardwarePolicy = lib.all (
        s:
        let
          f = s.features;
        in
        f.wakeOnPowerButtonOnly == f.development
        && f.cifsKeyutils
        && f.avr == f.development
        && f.stm32 == f.development
        && f.wakeUnit == f.development
        && f.requestKey
        && f.programmerRules.avr == f.development
        && f.programmerRules.stm32 == f.development
        && (
          if f.development then
            f.logind.HandlePowerKey == "suspend" && f.logind.HandleLidSwitch == "ignore"
          else
            !(f.logind ? HandlePowerKey) && !(f.logind ? HandleLidSwitch)
        )
      ) (builtins.attrValues snapshots);
      klPolicy = lib.all (
        s:
        let
          f = s.features;
        in
        f.klTrust == f.kl
        && f.klNssCertificates == (f.kl && f.graphical)
        && f.klNssTokens == (f.kl && f.graphical)
        && f.nssActivation.certificates == f.klNssCertificates
        && f.nssActivation.tokens == f.klNssTokens
        && (f.certificates != [ ]) == f.klTrust
      ) (builtins.attrValues snapshots);
      gamingHasNoKlTrust =
        !snapshots.ShvedGaming.features.klTrust && snapshots.ShvedGaming.features.certificates == [ ];
      servicePolicy = lib.all (
        s:
        let
          f = s.features;
        in
        f.gerrit == f.vps
        && f.gerritUnit == f.gerrit
        && f.gerritFirewall == f.gerrit
        && f.steam == f.gaming
        && f.gamingController == f.gaming
        && f.steamRemotePlay == f.gaming
      ) (builtins.attrValues snapshots);
    };
  errors.gerritDomain =
    (services [
      {
        services.gerrit.enable = true;
        services.gerrit.serverId = "test-only-server-identity";
      }
    ]).services.gerrit.settings.gerrit.canonicalWebUrl;
  errors.gerritServerId =
    (services [
      {
        services.gerrit.enable = true;
        services.vps.domain = "gerrit.example.invalid";
      }
    ]).services.gerrit.settings.gerrit.serverId;
  errors.standbyTimeout =
    (hardware [
      {
        hardware.drives."/dev/sda".standby.enable = true;
      }
    ]).systemd.services.hard-drive-standby-dev-sda.script;
}
