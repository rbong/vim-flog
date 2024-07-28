"
" This file contains miscellaneous functions for handling and checking options.
"

function! flog#opts#IsPatchImplied(opts) abort
  return !empty(a:opts.limit)
endfunction
