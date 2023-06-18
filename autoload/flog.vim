"
" This file contains public Flog API functions.
"

function! flog#Exec(cmd, ...) abort
  if empty(a:cmd)
    return ''
  endif

  let l:focus = get(a:, 1, v:false)
  let l:static = get(a:, 2, v:false)
  let l:tmp = get(a:, 3, v:false)

  if !flog#floggraph#buf#IsFlogBuf()
    exec a:cmd
    return a:cmd
  endif

  let l:graph_win = flog#win#Save()
  call flog#floggraph#side_win#Open(a:cmd, l:focus, l:tmp)

  if ! l:static
    if flog#win#Is(l:graph_win)
      call flog#floggraph#buf#Update()
    else
      call flog#floggraph#buf#InitUpdateHook(flog#win#GetSavedBufnr(l:graph_win))
    endif
  endif

  return a:cmd
endfunction

function! flog#ExecTmp(cmd, ...) abort
  let l:focus = get(a:, 1, v:false)
  let l:static = get(a:, 2, v:false)
  return flog#Exec(a:cmd, l:focus, l:static, v:true)
endfunction

function! flog#Format(cmd) abort
  return flog#format#FormatCommand(a:cmd)
endfunction

" Deprecations

function! flog#run_raw_command(...) abort
  call flog#deprecate#Function('flog#run_raw_command', 'flog#Exec')
endfunction

function! flog#run_command(...) abort
  call flog#deprecate#Function('flog#run_command', 'flog#Exec', 'flog#Format(...), ...')
endfunction

function! flog#run_tmp_command(...) abort
  call flog#deprecate#Function('flog#run_tmp_command', 'flog#ExecTmp')
endfunction
