{ lib, pkgs, config, ... }:
let
  kittyssh = pkgs.writeShellScript "kittyssh" ''
    if kitten ssh --help 2>/dev/null >/dev/null; then
      exec kitten ssh "$@"
    else
      exec ssh "$@"
    fi
  '';
in
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
        blesh.enable = true;
        enableCompletion = true;
        interactiveShellInit = let
          kitty-installation-dir = "${pkgs.kitty}/lib/kitty";
        in ''
          if [ -n "$KITTY_INSTALLATION_DIR" ]; then
              export KITTY_INSTALLATION_DIR="${kitty-installation-dir}"
          fi
          if [ -d "$KITTY_INSTALLATION_DIR" ]; then
              source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
          fi
        '';
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
          ssh = kittyssh;
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
