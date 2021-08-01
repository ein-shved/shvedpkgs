# /etc/bash.bashrc

# If not running interactively, don't do anything!
[[ $- != *i* ]] && return

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/gtk-2.0/modules/
# Enable history appending instead of overwriting.
shopt -s histappend

case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
    screen*)
        PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        ;;
esac

# fortune is a simple program that displays a pseudorandom message
# from a database of quotations at logon and/or logout.
# Type: "pacman -S fortune-mod" to install it, then uncomment the
# following line:

# [[ "$PS1" ]] && /usr/bin/fortune

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS. Try to use the external file
# first to take advantage of user additions. Use internal bash
# globbing instead of external grep binary.

# sanitize TERM:
safe_term=${TERM//[^[:alnum:]]/?}
match_lhs=""


export GIT_PS1_SHOWUPSTREAM="auto"
source @git_prompt@

[[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs} ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)

if [[ 1 ]] ; then

    # we have colors :-)

    # Enable colors for ls, etc. Prefer ~/.dir_colors
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    NETNS=$(ip netns identify ) 2> /dev/null
    if [ ! -z $NETNS ]; then
        NETNS='\[\033[00;33m\]'"$NETNS:"'\[\033[01m\]'
    fi
    # Use this other PS1 string if you want \W for root and \w for all other users:
    PS1="$(if [[ ${EUID} == 0 ]];
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
    #\$([[ \$? != 0 ]] && echo \"\[\033[01;31m\]:( \")


    if [ ! -z $SHORT_PROMPT ]; then
    PS1="$(if [[ ${EUID} == 0 ]]; then
            echo -n \$"(
                if [[ \$? == '0' ]]; then
                    echo -n '\[\033[01;36m\]#\[\033[00m\] ';
                else
                    echo -n '\[\033[01;31m\]#\[\033[00m\] ';
                fi)"
    else
            echo -n \$"(
                if [[ \$? == '0' ]]; then
                    echo -n '\[\033[01;36m\]$\[\033[00m\] ';
                else
                    echo -n '\[\033[01;31m\]$\[\033[00m\] ';
                fi)"
    fi)";
    fi;


    alias ls="ls --color=auto"
    alias dir="dir --color=auto"
    alias grep="grep --colour=auto"
    alias gtree="git log --oneline --graph"
    alias gs="git status"
else

    # show root@ when we do not have colors

    PS1="\u@\h \w \$([[ \$? != 0 ]] && echo \":( \")\$ "

    # Use this other PS1 string if you want \W for root and \w for all other users:
    # PS1="\u@\h $(if [[ ${EUID} == 0 ]]; then echo '\W'; else echo '\w'; fi) \$([[ \$? != 0 ]] && echo \":( \")\$ "

fi

#PS1='[\u@\h \W]\$ '


PS2="$(echo '\[\033[01;32m\]> \[\033[01;00m\]')"
PS3="> "
PS4="+ "

# Try to keep environment pollution down, EPA loves us.
unset safe_term match_lhs

# Try to enable the auto-completion (type: "pacman -S bash-completion" to install it).
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Try to enable the "Command not found" hook ("pacman -S pkgfile" to install it).
# See also: https://wiki.archlinux.org/index.php/Bash#The_.22command_not_found.22_hook
[ -r /usr/share/doc/pkgfile/command-not-found.bash ] && . /usr/share/doc/pkgfile/command-not-found.bash

#
# bashrc
#

#if [ -e $HOME/.bashrc ]
#then sh $HOME/.bashrc
#fi

#export WINEARCH=win32
#export WINEPREFIX=/home/shved/.wine32
#export MANPATH="$MANPATH":"$HOME/.cabal/share/doc":"/usr/share/doc"
#export PATH="$PATH":"$HOME/.cabal/bin"
#export PATH="$PATH":"/home/shved/usr/bin"
export EDITOR=vim
#export XDG_RUNTIME_DIR=$HOME/.xdg
#mkdir -p $XDG_RUNTIME_DIR
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/home/shved/usr/lib
