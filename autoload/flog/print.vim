"
" This file contains functions for printing messages.
"

function! flog#print#err(...) abort
  try
    echohl WarningMsg
    echomsg call('printf', a:000)
  finally
    echohl NONE
  endtry
endfunction
