"
" This file contains functions for working with Fugitive.
"

function! flog#fugitive#IsGitBuf() abort
  return FugitiveIsGitDir()
endfunction

function! flog#fugitive#GetGitDir() abort
  return FugitiveGitDir()
endfunction

function! flog#fugitive#SetupGitBuffer(workdir) abort
  call FugitiveDetect(a:workdir)
endfunction

function! flog#fugitive#Complete(arg_lead, cmd_line, cursor_pos) abort
  return fugitive#Complete(a:arg_lead, a:cmd_line, a:cursor_pos)
endfunction
