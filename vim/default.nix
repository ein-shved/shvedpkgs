{ pkgs, config }: with pkgs;
let
    shvedsPlugins = import ./vimplugins.nix { inherit pkgs config; };
    shvedsRc = import ./vimrc.nix { inherit pkgs config; };

    shvedsVim = vim_configurable.customize{
      name = "vim";
      wrapGui = true;
      vimrcConfig.packages.shvedsPlugins = shvedsPlugins;
      vimrcConfig.customRC = shvedsRc;
    };

in
    shvedsVim
