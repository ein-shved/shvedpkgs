{ ... }:
{
  imports = [
    ./applications
    ./config
    ./home
    ./security
    ./tools
    ./services/networking/cntlm-gss.nix
  ];
}

