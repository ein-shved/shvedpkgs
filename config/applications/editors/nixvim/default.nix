{ pkgs, pkgsUnstable, ... }:
{
  environment.systemPackages = with pkgs; [
    vim-configured
  ];
  environment.graphicPackages = with pkgsUnstable; [
    neovide
  ];
  environment.variables.EDITOR = "vim";
}
