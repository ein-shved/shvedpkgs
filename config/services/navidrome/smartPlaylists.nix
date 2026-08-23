{ lib, ... }:
let
  mkGenres =
    playlist: genres:
    playlist
    // {
      any = lib.map (genre: { is.genre = genre; }) genres;
    };
  mkUnion =
    playlist: others:
    playlist
    // {
      any = lib.map (other: { inPlaylist.path = "${other}.nsp"; }) others;
    };
in
{
  services.navidrome.smartPlaylists = {
    mdm =
      mkGenres
        {
          name = "Melodic Death Metal";
          public = true;
        }
        [
          "Atmospheric Melodic Death Metal"
          "Atmospheric"
          "Instrumental Symphonic Melodic Death Metal"
          "Melodic Death Metal"
          "Melodic Death Metal-Power Metal"
          "Melodic Death"
          "Modern Melodic Death Metal"
          "Progressive Melodic Death Metal"
          "Symphonic Death Metal"
          "Symphonic Melodic Death Metal"
          "Technical Melodic Death Metal"
          "Dark Cabaret Metal"
          "Folk Metal"
        ];
    death =
      mkGenres
        {
          name = "Death Metal";
          public = true;
        }
        [
          "Brutal Death Metal"
          "Death Metal"
          "Death"
          "Modern Death Metal"
          "Technical Death Metal"
        ];
    black =
      mkGenres
        {
          name = "Black Metal";
          public = true;
        }
        [
          "Black Metal"
          "Blackened Grindcore"
          "Dark Metal"
        ];
    cores =
      mkGenres
        {
          name = "XXX Core";
          public = true;
        }
        [
          "Metalcore"
          "Melodic Metalcore"
          "Hardcore"
          "Deathcore"
          "Grindcore"
          "Blackened Grindcore"
        ];
    power =
      mkGenres
        {
          name = "Power Metal";
          public = true;
        }
        [
          "Extreme Power Metal"
          "Melodic Death Metal-Power Metal"
          "Power Metal"
          "Power"
          "Symphonic Power Metal"
        ];
    punk =
      mkGenres
        {
          name = "Punk Rock";
          public = true;
        }
        [
          "Horror Punk"
          "Punk"
          "Punk Rock"
          "Ska Punk"
        ];
    metal =
      mkGenres
        {
          name = "Old School Metal";
          public = true;
        }
        [
          "Alternative Metal"
          "Altetnative Metal"
          "Avantgarde Metal"
          "Experemental Metal"
          "Experimental Metal"
          "Extreme Metal"
          "Groove Metal"
          "Heavy Metal"
          "Industrial Metal"
          "Industrial"
          "Metal"
          "Modern Metal"
          "Nu-Metal"
          "Power Metal"
          "Progressive Metal"
          "Thrash Metal"
        ];
  };
}
