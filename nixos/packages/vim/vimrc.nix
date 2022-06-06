{ pkgs, config, ... }:
let
  cfg = config.programs.vim;
  tabwidth = builtins.toString cfg.tabwidth;
  smalltabwidth = builtins.toString (cfg.tabwidth / 2);
  guirc = import ./guirc.nix { inherit pkgs config; };
  sessionrc = import ./sessionrc.nix { inherit pkgs config; };
  keymaprc = import ./keymaprc.nix { inherit pkgs config; };
  rnix-lsp-exe = "${pkgs.rnix-lsp.outPath}/bin/rnix-lsp";

in ''
  set nocompatible

"Highlighting
  syntax on
  set background=dark
  set spell spelllang=en

"Highlight next after linewidth column
  set tw=${builtins.toString cfg.linewidth}
  set colorcolumn=${builtins.toString (cfg.linewidth + 1)}
" Autoformating comments
  set formatoptions=croql

"Indentation
  set backspace=indent,eol,start
  set expandtab
  set autoindent
  set smartindent
  set tabstop=${tabwidth}
  set shiftwidth=${tabwidth}

"Diable wrapping
  set nowrap

"Searching
  set hlsearch

"Status line configuration
  set ruler
  set laststatus=2

"Session global part
  ${sessionrc.globals or ""}

"Gui heading part
  ${guirc.globals or ""}


  ${guirc.sessionselect or ""}

"Make vim to complete commands in the bash-like way:
" First tab hit complete to the longest match if possible
" If not - do nothing
" On the second tab hit show available matches
  set wildmode=longest,full,list

"We dont want to have swap file in project tree. Put them to special trash
"folder
  silent exec "!mkdir -p $HOME/.vim_swaps"
  set directory=$HOME/.vim_swaps

"Prepare encodings for the next block
  set encoding=utf-8
  scriptencoding utf-8

"Show special white characters
  set list
  set listchars=tab:→\ ,nbsp:␣,trail:•,precedes:«,extends:»

"Fix trailing whitespaces automatically
  autocmd BufWritePre *.c,*.h,*.cpp,*.hpp,*.lua,*.txt,*.sh,*.conf*,*.rb,*.py,*.scad,*.md,*.nix
    \ :%s/\s\+$//e

"Escape newlines for C macros easilly
  let g:easy_align_delimiters = {
    \ '\': {
    \   'pattern': '\\$',
    \   'delimiter_align': 'r',
    \ },
    \ }
  xmap <C-\>\ :EasyAlign<CR>\
  xmap <C-\><C-\> :s/\([^\\]\)$/\1\\/e<CR>:nohl<CR>gv:s/^$/\\/e<CR>:nohl<CR>gv:EasyAlign<CR>\
  nmap <C-\>] ggVG:EasyAlign<CR>\

"Speciffic filetypes commands
augroup vimrc_autocmds
"  "Dont use spaces in makefiles
"  autocmd FileType Makefile setlocal noexpandtab
"  autocmd FileType makefile setlocal noexpandtab
"  autocmd FileType automake setlocal noexpandtab
  "2 spaces preferred languages
  autocmd FileType xml,nix setlocal tabstop=${smalltabwidth}
  autocmd FileType xml,nix setlocal shiftwidth=${smalltabwidth}
  autocmd FileType gitcommit setlocal tw=72
  autocmd FileType gitcommit setlocal colorcolumn=73
  autocmd FileType markdown setlocal tw=${builtins.toString cfg.linewidth}
  autocmd FileType gitcommit,markdown setlocal formatoptions+=t
  "nospell languages
  autocmd FileType sh,shell,bash,txt setlocal nospell
augroup END

" vim -b : edit binary using xxd-format
augroup Binary
  au!
  au BufReadPre  *.bin,*.img let &bin=1
  au BufReadPost *.bin,*.img if &bin | silent %!xxd
  au BufReadPost *.bin,*.img set ft=xxd | endif
  au BufWritePre *.bin,*.img if &bin | silent %!xxd -r
  au BufWritePre *.bin,*.img endif
  au BufWritePost *.bin,*.img if &bin | silent %!xxd
  au BufWritePost *.bin,*.img set nomod | endif
augroup END


"FreeCad Macro files are python
  au BufReadPost *.FCMacro set syntax=python


"Special completion hint for c-file
  autocmd FileType c let b:vim_tab_complete = 'c'

"LSP
  let g:vcm_direction = 'p'
  let g:lsp_log_verbose = 0
  let g:lsp_log_file = expand('$XDG_RUNTIME_DIR/vim-lsp.log')
  let g:lsp_diagnostics_float_cursor=1
  let g:lsp_settings = { 'clangd': {'cmd':
    \ ['clangd', '-j=8',
    \            '--query-driver=${cfg.clangd.query_driver}',
    \            '--header-insertion=never' ]
    \ }}
  let g:lsp_document_code_action_signs_enabled=0
  let g:lsp_fold_enabled = 0
  let g:asyncomplete_auto_completeopt = 0
  let g:asyncomplete_auto_popup = 0
  let g:asyncomplete_popup_delay = 0

  set completeopt=menuone,noinsert,preview

  set foldmethod=expr
    \ foldexpr=lsp#ui#vim#folding#foldexpr()
    \ foldtext=lsp#ui#vim#folding#foldtext()

 "rnix-lsp see ReadMe of project
  if executable('${rnix-lsp-exe}')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'rnix-lsp',
    \ 'cmd': {server_info->[&shell, &shellcmdflag, '${rnix-lsp-exe}']},
    \ 'whitelist': ['nix'],
    \ })
  endif

"Gui process part
  ${guirc.generic or ""}

"Key Maps global
  ${keymaprc.globals or ""}
''
