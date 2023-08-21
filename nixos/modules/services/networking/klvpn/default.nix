{ config, lib, pkgs, ... }:
let
  cfg = config.services.klvpn;
  login = config.user.name;
in
{
  options = {
    services.klvpn = {
      enable = lib.mkEnableOption ''
        Does current system will use the vpn to kaspersky domain.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.klvpn
      pkgs.gnutls
    ];
    services.pcscd = {
      enable = true;
      # TODO(Shvedov) safenet driver uses outdated OPENSSL_1_1
      plugins = with pkgs; [
        pcsc-safenet
        pcsc-safenet-legacy
      ];
    };
    programs.gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    environment.etc = with pkgs; {
      "pkcs11/modules/libeToken.module" = {
        text = "module: ${pcsc-safenet}/lib/libeToken.so";
        mode = "0644";
      };
      "pkcs11/modules/libeTokenLegacy.module" = {
        text = "module: ${pcsc-safenet-legacy}/lib/libeToken.so";
        mode = "0644";
      };
    };
    programs.fuse.userAllowOther = true;
    #Allow to use token by non-root user
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_card" &&
          subject.user == "${login}") {
            return polkit.Result.YES;
        }
      });
      polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
          subject.user == "${login}") {
            return polkit.Result.YES;
        }
      });
    '';
    users.users."${login}".extraGroups = [
      "pkcs11" # Can ask about secure keys
    ];
  };
}
