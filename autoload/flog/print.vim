"
" This file contains functions for printing messages.
"

function! flog#print#err(...) abort
  echohl WarningMsg
  echomsg call('printf', a:000)
endfunction
