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
      tmp = {
        useTmpfs = true;
        cleanOnBoot = true;
      };
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
