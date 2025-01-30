"
" This file contains functions for working with the Git backend.
" Fugitive is used as the backend by default.
"

function! flog#backend#GetUserCommand() abort
  return get(g:, 'flog_backend_user_cmd', 'Git')
endfunction

function! flog#backend#GetUserSplitCommand() abort
  return get(g:, 'flog_backend_user_split_cmd', 'Gsplit')
endfunction

function! flog#backend#IsGitBuf() abort
  let l:fn = get(g:, 'flog_backend_is_git_buf_fn', 'FugitiveIsGitDir')
  return call(l:fn, [])
endfunction

function! flog#backend#GetGitDir() abort
  let l:fn = get(g:, 'flog_backend_get_git_dir_fn', 'FugitiveGitDir')
  return call(l:fn, [])
endfunction

function! flog#backend#SetupGitBuffer(workdir) abort
  let l:fn = get(g:, 'flog_backend_setup_git_buffer_fn', 'FugitiveDetect')
  call call(l:fn, [a:workdir])
endfunction

function! flog#backend#Complete(arg_lead, cmd_line, cursor_pos) abort
  let l:fn = get(g:, 'flog_backend_complete_fn', 'fugitive#Complete')
  return call(l:fn, [a:arg_lead, a:cmd_line, a:cursor_pos])
endfunction
