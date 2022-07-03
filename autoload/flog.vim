"
" This file contains public Flog API functions.
"

function! flog#ExecRaw(cmd, keep_focus, should_update, is_tmp) abort
  if !flog#floggraph#buf#IsFlogBuf()
    exec a:cmd
    return a:cmd
  endif

  let l:graph_win = flog#win#Save()
  call flog#floggraph#side_win#Open(a:cmd, a:keep_focus, a:is_tmp)

  if a:should_update
    if flog#win#Is(l:graph_win)
      call flog#floggraph#buf#Update()
    else
      call flog#floggraph#buf#InitUpdateHook(flog#win#GetSavedBufnr(l:graph_win))
    endif
  endif

  return a:cmd
endfunction

function! flog#Exec(cmd, keep_focus, should_update, is_tmp) abort
  call flog#floggraph#buf#AssertFlogBuf()

  let l:formatted_cmd = flog#exec#Format(a:cmd)
  if empty(l:formatted_cmd)
    return ''
  endif

  return flog#ExecRaw(l:formatted_cmd, a:keep_focus, a:should_update, a:is_tmp)
endfunction

function! flog#ExecTmp(cmd, keep_focus, should_update) abort
  return flog#Exec(a:cmd, a:keep_focus, a:should_update, v:true)
endfunction

" Deprecations

function! flog#run_raw_command(...) abort
  call flog#deprecate#Function('flog#run_raw_command', 'flog#ExecRaw')
endfunction

function! flog#run_command(...) abort
  call flog#deprecate#Function('flog#run_command', 'flog#Exec')
endfunction

function! flog#run_tmp_command(...) abort
  call flog#deprecate#Function('flog#run_tmp_command', 'flog#ExecTmp')
endfunction
