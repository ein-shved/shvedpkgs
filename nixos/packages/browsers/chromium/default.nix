{ lib, config, pkgs, ... }:
let
  cfg = config.programs.chromium;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.google-chrome
    ];
    programs.chromium = {
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
}
