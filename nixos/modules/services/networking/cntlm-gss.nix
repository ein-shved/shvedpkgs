{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.cntlm-gss;
  configFile = if cfg.configText != "" then
    pkgs.writeText "cntlm.conf" ''
      ${cfg.configText}
    ''
    else
    pkgs.writeText "cntlm.conf" ''
      # Cntlm GSS Authentication Proxy Configuration
      Username
      Domain
      Password
      ${optionalString (cfg.netbios_hostname != "") "Workstation ${cfg.netbios_hostname}"}
      ${concatMapStrings (entry: "Proxy ${entry}\n") cfg.proxy}
      ${concatMapStrings (entry: "Listen ${entry}\n") cfg.listen}
      ${concatMapStrings (entry: "NoProxy ${entry}\n") cfg.noproxy}
      ${concatMapStrings (entry: "${entry}\n") cfg.allowdeny}
      ${cfg.extraConfig}
    '';
  user = if (cfg.user != null) then cfg.user else "cntlm";
in
{

  options.services.cntlm-gss = {

    enable = mkEnableOption (lib.mdDoc "cntlm-gss, which starts a local proxy");


    netbios_hostname = mkOption {
      type = types.str;
      default = "";
      description = lib.mdDoc ''
        The hostname of your machine.
      '';
    };

    proxy = mkOption {
      type = types.listOf types.str;
      description = lib.mdDoc ''
        A list of NTLM/NTLMv2 authenticating HTTP proxies.
        Parent proxy, which requires authentication. The same as proxy on the command-line, can be used more than  once  to  specify  unlimited
        number  of  proxies.  Should  one proxy fail, cntlm automatically moves on to the next one. The connect request fails only if the whole
        list of proxies is scanned and (for each request) and found to be invalid. Command-line takes precedence over the configuration file.
      '';
      example = [ "proxy.example.com:81" ];
    };

    noproxy = mkOption {
      description = lib.mdDoc ''
        A list of domains where the proxy is skipped.
      '';
      default = [];
      type = types.listOf types.str;
      example = [ "*.example.com" "example.com" ];
    };

    listen = mkOption {
      default = [ "127.0.0.1:3128" ];
      type = types.listOf types.str;
      description = ''
        Specifies on which addresses the cntlm daemon listens.
      '';
    };

    allowdeny = mkOption {
      default = [
        "Allow 127.0.0.1"
        "Deny 0/0"
      ];
      type = types.listOf types.str;
      description = ''
        Allow/restrict certain IPs.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = lib.mdDoc "Additional config appended to the end of the generated {file}`cntlm.conf`.";
    };

    configText = mkOption {
       type = types.lines;
       default = "";
       description = lib.mdDoc "Verbatim contents of {file}`cntlm.conf`.";
    };

    user = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = lib.mdDoc "Username for daemon.";
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.services.cntlm-gss = {
      description = "CNTLM is an NTLM / NTLM Session Response / NTLMv2 authenticating HTTP proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = user;
        ExecStart = ''
          ${pkgs.cntlm-gss}/bin/cntlm -U cntlm -a gss -c ${configFile} -v -f
        '';
      };
    };

    networking.proxy = {
      default = "http://127.0.0.1:3128/";
      noProxy = concatMapStrings (entry: "${entry},") cfg.noproxy;
    };

    users = mkIf (cfg.user == null) {
      users.cntlm = {
        name = "cntlm";
        description = "cntlm system-wide daemon";
        isSystemUser = true;
        group = "cntlm";
      };
      groups.cntlm = {};
    };
  };
}
