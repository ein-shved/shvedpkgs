{ pkgs, config, ... }:
let
  sessionrc = import ./sessionrc.nix { inherit pkgs config; };
  keymaprc = import ./keymaprc.nix { inherit pkgs config; };
  maximized = let
    wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
    pkg = pkgs.writeShellScriptBin "maximized" ''
      pid=$1
      [ -z "$pid" ] && exit 0
      winid=""
      echo "PPID: $pid"
      n=0
      while [ -z "$winid" ]; do
        sleep 0.05
        winid=`${wmctrl} -pl |\
          grep -P "^0x[0-9a-f]+[ ]+[-0-9]+[ ]+$pid" |\
          cut -f1 -d' '`
        [ n -gt 500 ] && exit 1
        n=$(( $n + 1))
      done
      echo "winid: $winid"
      ${wmctrl} -i -b add,maximized_vert,maximized_horz -r $winid
    '';
  in "${pkg}/bin/maximized";

  getFontSize = let
    name = "get_vim_font_size";
    bigf = builtins.toString (config.programs.vim.fontsize + 1);
    smallf =  builtins.toString config.programs.vim.fontsize;
    pkg = pkgs.writeShellScriptBin name ''
      X=$(xrandr --current |\
          grep '*' | sed 's/x/ /'\
          |  awk 'BEGIN{a=   0}{if ($1>0+a) a=$1} END{print a}')
      if [ $X -gt 1920 ]; then
        S=${bigf}
      else
        S=${smallf}
      fi
      echo $S
    '';
  in "${pkg}/bin/${name}";
  font = ''JetBrains\\ Mono\\ Bold\\ '';

in
{

  globals = ''
  "We are want to use vim as IDE in graphic mode. We assume that any time
  "when vim runs in GUI it should turns to IDE.
    if ( has("gui_running") || exists("g:pseudo_gui") )
      let g:ide_running = 1
    else
      let g:ide_running = 0
    endif
  '';

  generic = ''
    set guioptions=a
    let g:guifontset = ":set guifont=${font}" . system('${getFontSize}')

    if g:ide_running
      colorscheme solarized
      highlight Cursor guifg=white guibg=blue
      ${keymaprc.ide or ""}
      set cursorline
      hi cursorline cterm=none term=none
      autocmd WinEnter * setlocal cursorline
      autocmd WinLeave * setlocal nocursorline
      highlight CursorLine guibg=#303000 ctermbg=234
      au GUIEnter * call system("${maximized} $PPID >/tmp/debug.txt&")
      au VimResized * wincmd =
      au VimResized * exec guifontset
    else
      "Fix mouse inside tmux terminal
      set ttymouse=xterm2
      set mouse=a
      if &term =~ '^screen'
        " tmux will send xterm-style keys when its xterm-keys option is on
        execute "set <xUp>=\e[1;*A"
        execute "set <xDown>=\e[1;*B"
        execute "set <xRight>=\e[1;*C"
        execute "set <xLeft>=\e[1;*D"
      endif
      ${sessionrc.noide or ""}
      ${keymaprc.noide or ""}
    endif
  '';
  sessionselect = ''
    if g:ide_running
      ${sessionrc.ide or ""}
    else
      ${sessionrc.noide or ""}
    endif
  '';
}
