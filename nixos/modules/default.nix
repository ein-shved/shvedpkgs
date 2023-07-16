{ ... }:
{
  imports = [
    ./config
    ./home
    ./services/networking/cntlm-gss.nix
    ./applications/emulators/wine
    ./services/3d-print
  ];
}

