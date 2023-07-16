{ pkgs, ... }:
{
  config.environment.etc.inputrc = {
    text = ''
      "\e[A": history-search-backward
      "\e[B": history-search-forward

      set bell-style none
      set colored-stats on
      set completion-ignore-case on
      set completion-prefix-display-length 3
      set mark-symlinked-directories on
      set show-all-if-ambiguous on
      set show-all-if-unmodified on
      set visible-stats on
    '';
    mode = "0644";
  };
}
