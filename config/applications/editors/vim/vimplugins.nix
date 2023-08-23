{ pkgs, config, ... }: with pkgs.vimPlugins;
let
  vim-lsp-settings = pkgs.vimUtils.buildVimPlugin {
    name = "vim-lsp-settings";
    src = pkgs.fetchFromGitHub {
      owner = "mattn";
      repo = "vim-lsp-settings";
      rev  = "b5c674592a89bff3539192ec26e84383dd68ab4a";
      sha256 = "1RUkziNfjgq5SdBRXrx/0r+hiBspuBiSBWpmx6ouqRo=";
    };
    dontBuild = true;
  };
  vim-expand-backspace = pkgs.vimUtils.buildVimPlugin {
    name = "vim-expand-backspace";
    src = pkgs.fetchFromGitHub {
      owner = "ein-shved";
      repo = "vim-expand-backspace";
      rev  = "8465fdd292ab2a0ee09867836c8c42be2ec655fe";
      sha256 = "0ilm05l4aimxr9ig1ayzcn0c1ilnmvw394yn0rrrrw16c8hvvq3j";
     };
  };
  asyncomplete-lsp = pkgs.vimUtils.buildVimPlugin {
    name = "asyncomplete-lsp";
    src = pkgs.fetchFromGitHub {
      owner = "prabirshrestha";
      repo = "asyncomplete-lsp.vim";
      rev  = "cc5247bc268fb2c79d8b127bd772514554efb3ee";
      sha256 = "SeEAy/jtrdHerZPVjQZXANTcuvMndIIWgGh3B8Ik1NM=";
     };
  };
in {
  start = [
    vim-nix               # From Nix docs
    vim-lastplace         # From Nix docs
    Solarized             # Lovely colors
    easy-align            # Plugin to format spaces
    vim-expand-backspace  # My own plugin to greedy remove spaces

    # LSP
    vim-lsp
    vim-lsp-cxx-highlight
    asyncomplete-vim
    asyncomplete-lsp
    vim-lsp-settings
  ];
  opt = [];
}
