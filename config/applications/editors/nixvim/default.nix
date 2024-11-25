{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim-configured
    neovide
  ];
  environment.variables.EDITOR = "vim";
}
