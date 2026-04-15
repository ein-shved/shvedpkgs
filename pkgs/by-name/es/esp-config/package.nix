{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "esp-config";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "esp-rs";
    repo = "esp-hal";
    rev = "esp-hal-v1.0.0";
    hash = "sha256-P+W1QlDO0tg277837FLS+Ko3my3HswgOSYq3zjS6Q9g=";
  };

  sourceRoot = "${src.name}/${pname}";

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  buildFeatures = [ "tui" ];
}
