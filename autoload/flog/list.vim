"
" This file contains functions for handling lists.
"

function! flog#list#Exclude(list, filters) abort
  return filter(copy(a:list), 'index(a:filters, v:val) < 0')
endfunction
