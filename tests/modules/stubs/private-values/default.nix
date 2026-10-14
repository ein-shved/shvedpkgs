{ lib, ... }:
{
  age.secrets.cloudflare.file = ./secrets/cloudflare.age;
  age.secrets.lastfm-navidrome.file = ./secrets/lastfm-navidrome.age;

  services.vps.domain = lib.mkDefault "validation.invalid";
}
