{ ... }:
{
  imports = [
    ./applications
    ./config
    ./hardware
    ./home
    ./security
    ./services/networking/cntlm-gss.nix
    ./tools
  ];
}

