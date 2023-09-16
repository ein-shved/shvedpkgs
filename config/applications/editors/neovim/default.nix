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
          rnix-lsp
          lua-language-server
          # TODO(Shvedov) use neocmakelsp after 23.11
          #neocmakelsp
          cmake-language-server
          nodePackages.bash-language-server
        ];
      };
    };
    environment.systemPackages = with pkgs; [
      neovide
    ];
  };
}
