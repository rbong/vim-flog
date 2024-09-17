"
" This file contains functions for working with shell commands.
"

function! flog#shell#Escape(str) abort
  if a:str =~# '^[A-Za-z0-9_/:.-]*$'
    return a:str
  elseif has('win32') && &shellcmdflag !~# '^-'
    " Escape in Windows shell
    return '"' . s:gsub(s:gsub(a:str, '"', '""'), '\%', '"%"') . '"'
  else
    return shellescape(a:str)
  endif
endfunction

function! flog#shell#EscapeList(list) abort
  return map(copy(a:list), 'flog#shell#Escape(v:val)')
endfunction

function! flog#shell#Run(cmd) abort
  let l:output = systemlist(a:cmd)
  if !empty(v:shell_error)
    call flog#print#err(join(l:output, "\n"))
    throw g:flog_shell_error
  endif
  return l:output
endfunction
