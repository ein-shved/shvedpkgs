{ pkgs, config }:
let
  globals = ''
"This maps make between-windows jumping more comfortable
  map <C-w><C-Up> <C-w><Up>
  map <C-w><C-Down> <C-w><Down>
  map <C-w><C-Right> <C-w><Right>
  map <C-w><C-Left> <C-w><Left>
  map <C-Up> <C-w><Up>
  map <C-Down> <C-w><Down>
  map <C-Right> <C-w><Right>
  map <C-Left> <C-w><Left>

" Map F9 to silent make and F10, F11 to jumping
  map <F9> :silent make<CR>
  map <F10> :cnext<CR>
  map <F11> :cprevious<CR>

" Mapping LSP integraion
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  inoremap <expr> <cr>  pumvisible() ? asyncomplete#close_popup() : "\<cr>"
  map <C-]> :LspDefinition<cr>

  let g:asyncomplete_auto_popup = 0

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

  inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ asyncomplete#force_refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  map <M-c> :LspCodeAction<cr>
  map <M-r> :LspRename<cr>
'';

  ide = ''
"Map Ctrl + c to copy to global buffer
  map <C-c> "+y<CR>
"Map Ctrl + x to cut to global buffer
  map <C-x> "+x<CR>
"Map Ctrl + p to paste from global buffer
"   This conflicts with special visual mode
"   map <C-v> "+p<CR>

" Make shift-insert work like in Xterm
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>

"LSP in IDE
  map <C-[> :LspNextReference<cr>
  map <C-S-[> :LspPreviousReference<cr>
'';

in
{ inherit globals ide; }
