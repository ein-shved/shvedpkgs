{ pkgs, config, ... }:
{
  config = {
    environment.graphicPackages = [
      pkgs.chromium
    ];
    # programs.chromium = {
    #   enable = config.hardware.needGraphic;
    #   defaultSearchProviderSearchURL = ''
    #     https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}
    #   '';
    #   defaultSearchProviderSuggestURL = ''
    #     https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}
    #   '';
    #   extraOpts = {
    #     "PasswordManagerEnabled" = false;
    #     "SpellcheckEnabled" = true;
    #     "SpellcheckLanguage" = [
    #       "ru-RU"
    #       "en-US"
    #     ];
    #   };
    # };
  };
}
