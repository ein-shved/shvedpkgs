{
  config,
  lib,
  ...
}:

let
  cfg = config.services.nginx.proxies;

  proxyType = lib.types.attrsOf (
    lib.types.submodule {
      options = {
        extraConfig = lib.mkOption {
          type = with lib.types; attrsOf anything;
          default = { };
          description = "Extra nginx configuration for this server block";
        };
        locations = lib.mkOption {
          description = "Paths for redirects";
          type = locationType;
          default = { };
        };
      };
    }
  );

  locationType = lib.types.attrsOf (
    lib.types.submodule {
      options = {
        upstreamPort = lib.mkOption {
          type = lib.types.port;
          description = "Local upstream http port";
        };
        extraConfig = lib.mkOption {
          type = with lib.types; attrsOf anything;
          default = { };
          description = "Extra nginx configuration for this path block";
        };
      };
    }
  );
in
{
  options.services.nginx.proxies = lib.mkOption {
    description = "Proxy configurations for domains";
    type = proxyType;
    default = { };
  };

  config.services.nginx = lib.mkIf (cfg != { }) {
    enable = true;
    virtualHosts = lib.mapAttrs (
      domain: proxyCfg:
      {
        forceSSL = true;
        locations = lib.mapAttrs (
          location: locationCfg:
          {
            proxyPass = "http://127.0.0.1:${toString locationCfg.upstreamPort}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            ''
            + locationCfg.extraConfig.extraConfig or "";
          }
          // lib.removeAttrs locationCfg.extraConfig [ "extraConfig" ]
        ) proxyCfg.locations;
      }
      // proxyCfg.extraConfig
    ) cfg;
  };
}
