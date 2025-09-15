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
    rev = "5aa353334404d57d7f1db4396e75a1676be802a6";
    hash = "sha256-OhbauBPXdu9j2XC9JABXcCclzmiSh3b/u1LVNy76Hbk=";
  };
  cargoHash = "sha256-3I8UnEyFnwEv9GJZ9/Z9IRAOUTIigIJr5hujNOD9p90=";
}
