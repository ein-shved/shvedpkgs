{ lib, pkgs, ... }:
let
  git_root = pkgs.gitAndTools.gitFull;
  git_prompt = "${git_root}/share/git/contrib/completion/git-prompt.sh";
  bash_completion =
    "${pkgs.bash-completion}/share/bash-completion/bash_completion";
  nix_index = "${pkgs.nix-index}/etc/profile.d/command-not-found.sh";
  ip = "${pkgs.iproute2}/bin/ip";
in
{
  imports = [ ./inputrc.nix ];
  config.programs = {
    command-not-found.enable = false; # Use nix-index instead
    bash = {
      interactiveShellInit = ''
        source ${nix_index}
        source ${bash_completion}

        export GIT_PS1_SHOWUPSTREAM="auto"
        source ${git_prompt}
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
      };
      undistractMe = {
        enable = true;
        playSound = true;
        timeout = 10;
      };
      vteIntegration = true;
      promptInit = ''
        NETNS=$(${ip} netns identify ) 2> /dev/null
        if [ ! -z $NETNS ]; then
          NETNS='\[\033[00;33m\]'"$NETNS:"'\[\033[01m\]'
        fi
        # Use this other PS1 string if you want \W for root and \w for all other users:
        PS1="$(if [[ $EUID == 0 ]];
        then
          echo -n "$NETNS"'\[\033[01;31m\]\h\[\033[01;00m\]'
          echo -n \$"(__git_ps1 '" %s"')"
          echo -n '\[\033[01;34m\] [ \[\033[01;35m\]\W \[\033[01;34m\]]\[\033[01;34m\]\[\033[00m\]';
          echo -n \$"(
          if [[ \$? == '0' ]];
          then
            echo -n ' \[\033[01;36m\]#\[\033[00m\] ';
          else
            echo -n ' \[\033[01;31m\]#\[\033[00m\] ';
          fi)"
        else
          echo -n '\[\033[01;32m\]\u\[\033[01;34m\] @ '"$NETNS"'\[\033[01;32m\]\h\[\033[01;00m\]'
          echo -n \$"(__git_ps1 '" %s"')"
          echo -n '\[\033[01;34m\] [ \[\033[01;35m\]\W \[\033[01;34m\]]\[\033[00m\]';
          echo -n \$"(
          if [[ \$? == '0' ]];
          then
            echo -n ' \[\033[01;36m\]$\[\033[00m\] ';
          else
            echo -n ' \[\033[01;31m\]$\[\033[00m\] ';
          fi)"
        fi;
        )"
        PS2="$(echo '\[\033[01;32m\]> \[\033[01;00m\]')"
        PS3="> "
        PS4="+ "
      '';
    };
  };
}
