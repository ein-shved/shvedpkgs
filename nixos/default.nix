{ pkgs, ... }:
{
  imports = [
    ./user
    ./packages
    ./services
    ./desktop
    ./media
    ./bashrc
    ./tools
    ./kl
    ./pkgs
    ./modules
  ];
  config = {
    boot = {
      tmpOnTmpfs = true;
      #tmpOnTmpfsSize = "30%";
      cleanTmpDir = true;
      plymouth.enable = true;
      kernelParams = [ "quiet" ];
      supportedFilesystems = [ "ntfs" ];
    };
    nix.settings.auto-optimise-store = true;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
