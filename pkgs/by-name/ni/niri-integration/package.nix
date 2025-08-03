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
    rev = "9da9fe0837645c5247d5bd3b18bc1f68d0c94469";
    hash = "sha256-dk0+GF9Qmmdbz4nFL8aIARjIyJIyqMb3XqXegjOzabk=";
  };
  cargoHash = "sha256-3I8UnEyFnwEv9GJZ9/Z9IRAOUTIigIJr5hujNOD9p90=";
}
