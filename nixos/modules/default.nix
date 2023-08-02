{ ... }:
{
  imports = [
    ./applications
    ./config
    ./hardware
    ./home
    ./os-specific
    ./security
    ./services/networking/cntlm-gss.nix
    ./tools
  ];
}

