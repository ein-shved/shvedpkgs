{ pkgs, config }:
let
# Better to add ctags and cscope to systemPackages to prevent
# broken sessions after update.
  ctagsExe = "ctags";
  cscopeExe = "cscope";
  cdExe = "cd";
  functions = ''
  "Function to save all files and current session
    fu! SaveWithSession()
      exec "wa"
      exec "mksession!" . g:session_name_path
    endfunction
  '';
  clearUpAbsolutes = let
    name = "vim_session_clear_absilute_paths";
    pkg = pkgs.writeShellScriptBin name ''
      # Assume incoming file was generated with vim and each command on its
      # single line.
      sed -n '/\/nix\/store/!p' -i $1
    '';
  in
    "${pkg}/bin/${name}";

  globals = ''
  "Remember current PWD
    let g:exec_path = getcwd()

  "Where tagfile should be placed
    let g:tag_name_path = exec_path . "/tags"

  "Where session file should be placed
    let g:session_name_path = exec_path . "/.Session.vim"

  "Where cscope should be placed
    let g:cscope_name_path = exec_path . "/cscope.out"

  "Prepare two variables-commands for tags, ...
    let g:exec_tags = ":!${ctagsExe} " .
            \ "-R --C-kinds=+defgmstuv " .
            \ "--tag-relative=no " .
            \ "--c++-kinds=+p --fields=+iaS --extra=+q -f " .
            \ g:tag_name_path . " "  . g:exec_path
    let g:exec_tags_set = ":set tags=" . tag_name_path

  "variable-command for loading session
    let g:exec_session_set = ":source " . session_name_path

  "variable-command for tidying session
    let g:exec_tidy_session = ":!${clearUpAbsolutes} " . session_name_path

  "and for cscope
    set csre
    let g:exec_cscope = ":!${cdExe} " . exec_path . " && ${cscopeExe} -Rb"
    let g:exec_cscope_set = ":cs add " . g:cscope_name_path . " " . exec_path

  "This maps procedure of generating cags and cscope DB and then setting them to
  "the F8 hot key
    map <F8> :exec exec_tags<CR>:exec exec_tags_set<CR>:exec exec_cscope<CR>:exec exec_cscope_set<CR>
    map <C-F8> :exec exec_tags_set<CR>:exec exec_cscope_set<CR>

  "Jumping between tags
    map <F7> :tn<CR>
    map <F6> :tp<CR>

    ${functions}
'';

    ide = ''
  "If tags file is available - use it!
    if filereadable(g:tag_name_path)
        exec exec_tags_set
        exec exec_cscope_set
    endif

  "If session file is available - source it!
    if filereadable(g:session_name_path)
        silent exec exec_session_set
        "we are going to run tidy withing session start to
        "support old-generated sessions.
        silent exec exec_tidy_session
    endif
  "Map Ctrl+s to use our Save function
    map <C-s> :call SaveWithSession()<CR>
  "The same when we are in edit mode
    imap <C-s> <Esc>:call SaveWithSession()<CR>i<Right>
'';

in
{ inherit globals ide; }
