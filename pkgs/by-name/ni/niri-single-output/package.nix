{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "niri-single-output";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "ein-shved";
    repo = pname;
    rev = "cafaf90ef44cf9d4fe33a1352ffabb39fbca46ad";
    hash = "sha256-idHE6zQuKOb2KGI1ufi+sffdYBZgo7hr+xStj9Lv9Jg=";
  };
  cargoHash = "sha256-ZiGLAXqkVdI0Kb7mQG134o4jzDBNe9/1114AalfQAcM=";
}
