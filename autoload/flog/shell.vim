"
" This file contains functions for working with shell commands.
"

function! flog#shell#Escape(str) abort
  " Fix bug where '-' is escaped
  if a:str ==# '-'
    return a:str
  endif
  return escape(a:str, ' \t\n*?[]{}`$\\%#"|!<();&>' . "'")
endfunction

function! flog#shell#EscapeList(list) abort
  return map(copy(a:list), 'flog#shell#Escape(v:val)')
endfunction

function! flog#shell#Run(cmd) abort
  let l:output = systemlist(a:cmd)
  if !empty(v:shell_error)
    echoerr join(l:output, "\n")
    throw g:flog_shell_error
  endif
  return l:output
endfunction
