{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "niri-launcher";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "ein-shved";
    repo = pname;
    rev = "d21f012dcf2cfc797afbdc6cc4b5bcaf1207ebe5";
    hash = "sha256-VsJl46EPJLy3EpiTxHzDvS6zAddXJ9CqOfTvCfgmOlI=";
  };
  cargoHash = "sha256-D1IVkPStCRES3wiG3x7bPi7q6JwtVSVjSdjhBRX1iYY=";
}
