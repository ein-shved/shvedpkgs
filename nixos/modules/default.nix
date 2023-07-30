{ ... }:
{
  imports = [
    ./applications
    ./config
    ./home
    ./security
    ./tools
    ./services/3d-print
    ./services/networking/cntlm-gss.nix
  ];
}

