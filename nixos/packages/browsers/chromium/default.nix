{ lib, config, pkgs, ... }:
let
 # chromium_browser_krb = pkgs.chromium.browser.overrideAttrs (attrs: {
 #   gnFlags = lib.concatStringsSep " " [
 #     attrs.gnFlags
 #     "use_kerberos=true"
 #   ];
 # });
 # chromium_krb = pkgs.chromium.overrideAttrs (attrs: {
 #   browser = chromium_browser_krb;
 # });
  chromium_krb = pkgs.chromium.mkDerivation
  (base: {
    gnFlags = {
      use_kerberos = true;
    };
    name = "chromium_krb";
  });
  cfg = config.programs.chromium;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
#      (if cfg.useKerberos then chromium_krb else pkgs.chromium)
      pkgs.chromium
    ];
    programs.chromium = lib.mkIf cfg.enable {
      defaultSearchProviderSearchURL = ''
        https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}
      '';
      defaultSearchProviderSuggestURL = ''
        https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}
      '';
      extraOpts = {
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [ "ru-RU" "en-US" ];
      };
    };
  };
  options = {
    programs.chromium = {
      useKerberos = lib.mkEnableOption
        "rebuild Cromium with support of Kerberos";
    };
  };
}
