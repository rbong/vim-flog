"
" This file contains public Flog API functions.
"

function! flog#Version() abort
  return '3.0.0'
endfunction

function! flog#Exec(cmd, ...) abort
  let l:opts = get(a:, 1, {})
  if type(l:opts) != v:t_dict && type(l:opts) != v:t_list
    call flog#deprecate#ShowWarning('flog#Exec("cmd", focus, static, tmp)', 'flog#Exec("cmd", { "blur": !focus, "static": static, "tmp": tmp })')
    let l:opts = {}
  endif

  let l:blur = get(l:opts, 'blur', 0)
  let l:static = get(l:opts, 'static', 0)
  let l:tmp = get(l:opts, 'tmp', 0)

  if empty(a:cmd)
    return ''
  endif

  if !flog#floggraph#buf#IsFlogBuf()
    exec a:cmd
    return a:cmd
  endif

  let l:graph_win = flog#win#Save()
  let l:should_auto_update = flog#floggraph#opts#ShouldAutoUpdate()

  call flog#floggraph#side_win#Open(a:cmd, l:blur, l:tmp)

  if !l:static && !l:should_auto_update
    if flog#win#Is(l:graph_win)
      call flog#floggraph#buf#Update()
    else
      call flog#floggraph#buf#InitUpdateHook(l:graph_win.bufnr)
    endif
  endif

  return a:cmd
endfunction

function! flog#ExecTmp(cmd, ...) abort
  let l:opts = get(a:, 1, {})
  if type(l:opts) != v:t_dict && type(l:opts) != v:t_list
    call flog#deprecate#ShowWarning('flog#ExecTmp("cmd", focus, static)', 'flog#ExecTmp("cmd", { "blur": !focus, "static": static })')
    let l:opts = {}
  endif

  return flog#Exec(a:cmd, extend({ 'tmp': 1 }, l:opts))
endfunction

function! flog#Format(cmd) abort
  return flog#floggraph#format#FormatCommand(a:cmd)
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
