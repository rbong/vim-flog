"
" This file contains functions for dealing with paths.
"

function! flog#path#IsAbs(path) abort
  return a:path =~# '^\([a-zA-Z]:\|[\\/]\)'
endfunction

function! flog#path#ResolveFrom(parent, path) abort
  let l:path = flog#path#IsAbs(a:path) ? a:path : a:parent .. '/' .. a:path
  return resolve(l:path)
endfunction
