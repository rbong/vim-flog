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

if has('nvim') || v:version > 704 || (v:version == 704 && get(v:, 'patchlevel', 0) >= 247)
  function! flog#shell#Systemlist(cmd) abort
    return systemlist(a:cmd)
  endfunction
else
  function! flog#shell#Systemlist(cmd) abort
    if type(a:cmd) == v:t_list
      return systemlist(join(a:cmd, ' '))
    endif
    return systemlist(a:cmd)
  endfunction
endif

function! flog#shell#Run(cmd) abort
  let l:output = flog#shell#Systemlist(a:cmd)
  if !empty(v:shell_error)
    call flog#print#err(join(l:output, "\n"))
    throw g:flog_shell_error
  endif
  return l:output
endfunction
