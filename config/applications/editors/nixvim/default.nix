{
  pkgs,
  pkgsUnstable,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (if config.hardware.development then vim-configured else vim-configured-nodev)
  ];
  environment.graphicPackages = with pkgsUnstable; [
    neovide
  ];
  environment.variables.EDITOR = "vim";
}
