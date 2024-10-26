"
" This file contains functions for working with shell commands.
"

function! flog#shell#Escape(str) abort
  if a:str =~# '^[A-Za-z0-9_/:.-]\+$'
    return a:str
  elseif has('win32') && &shellcmdflag !~# '^-'
    " Escape in Windows shell
    return '"' .. substitute(substitute(a:str, '"', '""', 'g'), '%', '"%"', 'g') .. '"'
  else
    return shellescape(a:str)
  endif
endfunction

function! flog#shell#EscapeList(list) abort
  return map(copy(a:list), 'flog#shell#Escape(v:val)')
endfunction

function! flog#shell#Systemlist(cmd) abort
  let l:cmd = a:cmd
  if type(a:cmd) == v:t_list
    let l:cmd = join(l:cmd, ' ')
  endif
  if has('win32')
    let l:result = split(system(l:cmd), '\n\r\?', 1)
    if empty(l:result[-1])
      return l:result[:-2]
    endif
    return l:result
  endif
  return systemlist(l:cmd)
endfunction

function! flog#shell#Run(cmd) abort
  let l:output = flog#shell#Systemlist(a:cmd)
  if !empty(v:shell_error)
    call flog#print#err(join(l:output, "\n"))
    throw g:flog_shell_error
  endif
  return l:output
endfunction
