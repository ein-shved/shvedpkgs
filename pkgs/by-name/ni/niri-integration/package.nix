{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "niri-integration";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "ein-shved";
    repo = pname;
    rev = "736de71324b044ba0dec89e8444bd103b2d90658";
    hash = "sha256-VsJl46EPJLy3EpiTxHzDvS6zAddXJ9CqOfTvCfgmOlU=";
  };
  cargoHash = "sha256-D1IVkPStCRES3wiG3x7bPi7q6JwtVSVjSdjhBRX1iYY=";
}
