{ stdenv, lib, pkgs, substituteAll }:
let
    git_root = pkgs.gitAndTools.gitFull;
    git_prompt = "${git_root}/share/git/contrib/completion/git-prompt.sh";
    bashrc = substituteAll {
        src = ./bash.bashrc;
        isExecutable = true;
        inherit git_prompt;
        inherit (stdenv) shell;
    };
in bashrc
