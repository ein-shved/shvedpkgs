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
        openssh = cfg.services.openssh.enable;
        transmission = cfg.services.transmission.enable;
        displayManager = cfg.services.displayManager.enable;
        git = cfg.programs.git.enable;
        certificates = map toString cfg.security.pki.certificateFiles;
      };
    };
in
lib.mapAttrs (_: snapshot) flake.nixosValidationConfigurations
