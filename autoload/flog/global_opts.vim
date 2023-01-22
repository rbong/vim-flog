"
" This file contains functions for working with global options.
"

function! flog#global_opts#GetOrderType(name) abort
  for l:order_type in g:flog_order_types
    if l:order_type.name ==# a:name
      return l:order_type
    endif
  endfor
  return {}
endfunction
