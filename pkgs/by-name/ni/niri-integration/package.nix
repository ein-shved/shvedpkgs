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
    rev = "9ebda4116ecdc9e14068f9340d1a915c2801fdd6";
    hash = "sha256-nvZ3CTNDT0eTRW9rMArDqZg5uVt6/6+TGzQ85BeSPbk=";
  };
  cargoHash = "sha256-3I8UnEyFnwEv9GJZ9/Z9IRAOUTIigIJr5hujNOD9p90=";
}
