{ lib, config, pkgs, ... }:
{
  config = {
    environment.systemPackages = [
      pkgs.google-chrome
    ];
    programs.chromium = {
      enable = true;
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
