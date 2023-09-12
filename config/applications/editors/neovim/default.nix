{ pkgs, nvchad, ... }:
{
  imports = nvchad.modules;
  config = {
    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      nvchad = {
        enable = true;
        custom = ./custom;
        runtimeInputs = with pkgs; [
          ctags
          cscope
          clang-tools
        ];
      };
    };
    environment.systemPackages = with pkgs; [
      neovide
    ];
  };
}
