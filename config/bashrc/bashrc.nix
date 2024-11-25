{ lib, pkgs, config, ... }:
{
  options = {
    programs.bash.extraCompletions = with lib; with types; mkOption {
      description = "Add your bash-completion script bpdy here";
      type = listOf str;
      default = [ ];
    };
  };
  config = {
    programs = {
      command-not-found.enable = false; # Use nix-index instead
      nix-index = {
        enable = true;
        enableBashIntegration = true;
      };
      bash = {
        enableCompletion = true;
        enableLsColors = true;
        shellAliases = {
          grep = "grep --colour=auto";
          gtree = "git log --oneline --graph";
          gs = "git status";
          ll = "ls -l";
          got = "git";
          gc = "git commit";
          gcm = "git commit --amend";
          gcmn = "git commit --amend --no-edit";
          grh = "git rebase -i HEAD";
          gt = "git checkout";
          gsh = "git show";
          icat = "kitten icat";
        };
        undistractMe = {
          enable = false;
          playSound = true;
          timeout = 10;
        };
        vteIntegration = true;
      };
    };
  };
}
