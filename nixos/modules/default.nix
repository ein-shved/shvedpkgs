{ ... }:
{
  imports = [
    ./applications
    ./config
    ./home
    ./security
    ./services/3d-print
    ./services/networking/cntlm-gss.nix
  ];
}

