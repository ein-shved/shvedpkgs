{ lib, pkgs, config, ... }:
let
  git_root = pkgs.gitAndTools.gitFull;
  git_prompt = "${git_root}/share/git/contrib/completion/git-prompt.sh";
  bash_completion =
    "${pkgs.bash-completion}/share/bash-completion/bash_completion";
  nix_index = "${pkgs.nix-index}/etc/profile.d/command-not-found.sh";
  ip = "${pkgs.iproute2}/bin/ip";
  completions =
    let
      cfg = config.programs.bash.extraCompletions;
      script = builtins.foldl' (r: n: r + "\n" + n) "" cfg;
      pkgname = "extraBashCompletions";
      pkg = pkgs.writeShellScriptBin pkgname script;
    in
    "${pkg}/bin/${pkgname}";

  ansiechoPkg =
    let
      ansi = "${pkgs.ansi}/bin/ansi";
    in
    pkgs.writeShellScriptBin "ansiecho" ''
      set -e
      start_escapes="true"
      end_escapes="true"
      if [ -n "$INSIDE_PS" ]; then
        start_escapes='echo -n \['
        end_escapes='echo -n \]'
      fi

      $start_escapes
      echo -en "$(${ansi} reset)";
      $end_escapes

      while [ "$1" != "--" ]; do
        $start_escapes
        echo -en "$(${ansi} "$1")";
        $end_escapes

        if ! shift; then
          break
        fi
      done
      if [ "$1" == "--" ]; then
        shift
      fi
      echo "$@"
      $start_escapes
      echo -en "$(${ansi} reset)";
      $end_escapes
    '';
  ansiecho = "INSIDE_PS=1 ${ansiechoPkg}/bin/ansiecho";
  ansiechoNoe = "${ansiechoPkg}/bin/ansiecho";

  simplescript = script:
    "${(pkgs.writeShellScriptBin "__script" script)}/bin/__script";

  userhost = simplescript ''
    if [ "$EUID" == "0" ]; then
      ${ansiecho} red bold -- -n '\h '
    else
      ${ansiecho} green bold -- -n '\u'
      ${ansiecho} blue bold -- -n ' @ '
      ${ansiecho} green bold -- -n '\h '
    fi
  '';
  check_call_subshell = simplescript ''
    [ -z "$SHLVL" ] && SHLVL=1
    SHLVL=$(($SHLVL - 1))
    if [ $SHLVL -le 1 ]; then
      exit 0
    fi
    if [ -z "$1" ]; then
      echo -n "$SHLVL"
    else
      echo -n "$@"
    fi
  '';
  check_call_nixdevelop = simplescript ''
    if [ -z "$NIX_BUILD_TOP" ] || [ -z "$name" ]; then
      exit 0
    fi
    echo -n " $name"
  '';
  place = script: ''
    '$(__result=$?; ${script}; exit $__result)'
  '';
  subshell = simplescript ''
    ${ansiecho} yellow bold -- -n ${place ''${check_call_subshell} "{ "''}
    ${ansiecho} cyan -- -n ${place check_call_subshell}
    ${ansiecho} red bold -- -n ${place check_call_nixdevelop}
    ${ansiecho} yellow bold -- -n ${place ''${check_call_subshell} " } "''}
  '';
  gitprompt_placed = simplescript ''
    source ${git_prompt}
    export GIT_PS1_SHOWUPSTREAM="auto"
    git="$(__git_ps1 %s)"
    if [ -n "$git" ]; then
      echo -n "$git ";
    fi
  '';
  gitprompt = simplescript ''
    echo -n ${place gitprompt_placed}
  '';
  workdir = simplescript ''
    ${ansiecho} blue bold -- -n '[ '
    ${ansiecho} purple bold -- -n '\W'
    ${ansiecho} blue bold -- -n ' ] '
  '';
  check_call_propmt = simplescript ''
    echo -n '$(if [ "$?" == "0" ]; then echo -n '"$1"'; else echo -n '"$2"'; fi)'
  '';
  prompt1 = simplescript ''
    if [ "$EUID" == "0" ]; then
      prompt="#";
    else
      prompt="$";
    fi
    ${check_call_propmt} \
      "$(${ansiecho} cyan bold -- -n "$prompt ")" \
      "$(${ansiecho} red bold -- -n "$prompt ")"
  '';
  prompt2 = simplescript ''
    ${ansiecho} green bold -- -n '> '
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
    environment.systemPackages = [
      ansiechoPkg
    ];
    programs = {
      command-not-found.enable = false; # Use nix-index instead
      bash = {
        interactiveShellInit = ''
          source ${nix_index}
          source ${bash_completion}
          source ${completions}
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
        };
        undistractMe = {
          enable = true;
          playSound = true;
          timeout = 10;
        };
        vteIntegration = true;
        promptInit = ''
          PS1="$(
            ${userhost}
            ${subshell}
            ${gitprompt}
            ${workdir}
            ${prompt1}
          )"
          PS2="$(${prompt2})"
          PS3="> "
          PS4="+ "
        '';
      };
    };
  };
}
