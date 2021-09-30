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
  };
}
