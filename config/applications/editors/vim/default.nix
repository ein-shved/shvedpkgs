{ pkgs, config, lib, ... }:
let
  plugins = import ./vimplugins.nix { inherit pkgs config; };
  vimrc = import ./vimrc.nix { inherit pkgs config;  };

  vim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig.packages.plugins = plugins;
    vimrcConfig.customRC = vimrc;
  };
  vimdiff = pkgs.writeShellScriptBin "vimdiff" ''
    exec ${vim}/bin/vim -d "$@"
  '';
  default_query_driver = ["/nix/store/**/*" "*"];
in
{
  config = {
    environment = {
      systemPackages = [
        vim
        vimdiff
        pkgs.ctags
        pkgs.cscope
        pkgs.jetbrains-mono
        pkgs.clang-tools
      ];
    };
    programs.vim = {
      package = vim;
      clangd.query_driver = default_query_driver;
    };
  };
  options = {
    programs.vim = with lib; {
      clangd = {
        query_driver = mkOption {
          description = ''
            The -query-driver option strings for launching clangd server
          '';
          type = types.listOf types.str;
          default = default_query_driver;
        };
      };
      tabwidth = mkOption {
        description = ''
          The length of tabulation ansd shifting in spaces
        '';
        type = types.ints.positive;
        default = 4;
      };
      linewidth = mkOption {
        description = ''
          The limit of line length
        '';
        type = types.ints.positive;
        default = 80;
      };
      fontsize = mkOption {
        description = ''
          Font size for GUI
        '';
        type = types.ints.positive;
        default = 9;
      };
    };
  };
}
