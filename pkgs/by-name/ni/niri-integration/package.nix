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
    rev = "b3b2f81375e78e4361f175839a2ae86751bfb1c9";
    hash = "sha256-53WCWJ995aPCXBySuzdxwbCLiU4r02JaS54hhiv2eOg=";
  };
  cargoHash = "sha256-3I8UnEyFnwEv9GJZ9/Z9IRAOUTIigIJr5hujNOD9p90=";
}
