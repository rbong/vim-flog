"
" This file contains functions for working with strings.
"

function! flog#str#Ellipsize(str, max_len) abort
  if len(a:str) > a:max_len
    return a:str[ : a:max_len - 4] . '...'
  endif

  return a:str
endfunction
