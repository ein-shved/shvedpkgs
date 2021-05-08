{ pkgs, config }: with pkgs.vimPlugins;
let
    vim-lsp-settings = pkgs.vimUtils.buildVimPlugin {
        name = "vim-lsp-settings";
        src = pkgs.fetchFromGitHub {
            owner = "mattn";
            repo = "vim-lsp-settings";
            rev  = "b37de024025cc34ee5f422fcf3638da99851e243";
            sha256 = "12qbxr28q36xkc3zh1z48iy1x1724lmf319x4p66p72ynaa913xm";
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
            rev  = "684c34453db9dcbed5dbf4769aaa6521530a23e0";
            sha256 = "0vqx0d6iks7c0liplh3x8vgvffpljfs1j3g2yap7as6wyvq621rq";
         };
    };

in {
    start = [
                vim-nix         # From Nix docs
                vim-lastplace   # From Nix docs
                NeoSolarized    # Lovely colors
                easy-align      # Plugin to format spaces
                vim-expand-backspace # My own plugin to greedy remove spaces

             # LSP
                vim-lsp
                vim-lsp-cxx-highlight
                asyncomplete-vim
                asyncomplete-lsp
                vim-lsp-settings
             ];
    opt = [];
}
