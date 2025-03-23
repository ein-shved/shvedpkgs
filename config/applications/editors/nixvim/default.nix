{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim-configured
  ];
  environment.graphicPackages = with pkgs; [
    neovide
  ];
  environment.variables.EDITOR = "vim";
}
