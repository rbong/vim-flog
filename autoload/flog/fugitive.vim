"
" This file contains functions for working with Fugitive.
"

function! flog#fugitive#IsGitBuf() abort
  return FugitiveIsGitDir()
endfunction

function! flog#fugitive#GetRelativePath(workdir, path) abort
  let l:full_path = fnamemodify(a:path, ':p')
  if stridx(l:full_path, a:workdir) == 0
    return l:full_path[len(a:workdir) + 1 : ]
  endif
  return a:path
endfunction

function! flog#fugitive#GetWorkdir() abort
  return FugitiveFind(':/')
endfunction

function! flog#fugitive#GetGitDir() abort
  return FugitiveGitDir()
endfunction

function! flog#fugitive#GetGitCommand() abort
  return FugitiveShellCommand()
endfunction

function! flog#fugitive#GetHead() abort
  return fugitive#Head()
endfunction

function! flog#fugitive#TriggerDetection(workdir) abort
  call FugitiveDetect(a:workdir)
  return a:workdir
endfunction

function! flog#fugitive#Complete(arg_lead, cmd_line, cursor_pos) abort
  return fugitive#Complete(a:arg_lead, a:cmd_line, a:cursor_pos)
endfunction
