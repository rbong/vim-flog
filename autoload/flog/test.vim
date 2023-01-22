"
" This file contains utils only for use in tests.
"

function! flog#test#Assert(cmd) abort
  if !eval(a:cmd)
    echoerr a:cmd
  endif
endfunction
