{ config, pkgs, ... }:
{
  config = {
    local.home.file = {
      ".toprc".source = ./toprc;
    };
  };
}
