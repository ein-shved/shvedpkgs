{ pkgs, config }:
let
  sessionrc = import ./sessionrc.nix { inherit pkgs config; };
  keymaprc = import ./keymaprc.nix { inherit pkgs config; };
  font = ''JetBrains\ Mono\ Bold\ 8'';
in ''
"We are want to use vim as IDE in graphic mode. We assume that any time
"when vim runs in GUI it should turns to IDE.
  set guioptions=a
  set guifont=${font}

  if ( has("gui_running") || exists("g:pseudo_gui") )
    let g:ide_running = 1
  else
    let g:ide_running = 0
  endif

  if g:ide_running
    colorscheme NeoSolarized
    highlight Cursor guifg=white guibg=blue
    ${sessionrc.ide or ""}
    ${keymaprc.ide or ""}
    set cursorline
    hi cursorline cterm=none term=none
    autocmd WinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
    highlight CursorLine guibg=#303000 ctermbg=234
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
''
