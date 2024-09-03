"
" This file contains functions for handling side windows in "floggraph" buffers.
"

function! flog#floggraph#side_win#CloseTmp() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:prev_win = flog#win#Save()

  for l:tmp_id in l:state.tmp_side_wins
    " Buffer is not open
    if win_id2tabwin(l:tmp_id) == [0, 0]
      continue
    endif

    " Buffer is open, close
    call win_gotoid(l:tmp_id)
    silent! close!
  endfor

  call flog#win#Restore(l:prev_win)

  return flog#state#ResetTmpSideWins(l:state)
endfunction

function! flog#floggraph#side_win#IsInitialized() abort
  return exists('b:flog_side_win_initialized')
endfunction

function! flog#floggraph#side_win#Initialize(state, is_tmp) abort
  if !flog#state#HasBufState()
    call flog#state#SetBufState(a:state)
  endif

  call flog#deprecate#Autocmd('FlogCmdBufferSetup', 'FlogSideWinSetup')
  call flog#deprecate#Autocmd('FlogTmpCmdBufferSetup', 'FlogTmpSideWinSetup')
  call flog#deprecate#Autocmd('FlogNonTmpCmdBufferSetup', 'FlogNonTmpSideWinSetup')

  if exists('#User#FlogSideWinSetup')
    doautocmd User FlogSideWinSetup
  endif

  if a:is_tmp
    if exists('#User#FlogTmpSideWinSetup')
      doautocmd User FlogTmpSideWinSetup
    endif
  else
    if exists('#User#FlogNonTmpSideWinSetup')
      doautocmd User FlogNonTmpSideWinSetup
    endif
  endif

  let b:flog_side_win_initialized = v:true

  return win_getid()
endfunction

function! flog#floggraph#side_win#Open(cmd, blur, is_tmp) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if a:is_tmp
    call flog#floggraph#side_win#CloseTmp()
  endif

  let l:graph_win = flog#win#Save()
  let l:saved_win_ids = flog#win#GetAllIds()

  exec a:cmd
  let l:final_win = flog#win#Save()

  let l:new_win_ids = flog#win#GetAllIds()
  let l:new_win_ids = flog#list#Exclude(l:new_win_ids, l:saved_win_ids)

  if !empty(l:new_win_ids)
    call flog#win#Restore(l:graph_win)

    for l:win_id in l:new_win_ids
      silent! call win_gotoid(l:win_id)
      if !flog#floggraph#side_win#IsInitialized()
        call flog#floggraph#side_win#Initialize(l:state, a:is_tmp)
      endif
    endfor

    call flog#win#Restore(l:final_win)

    if a:is_tmp
      call flog#state#SetTmpSideWins(l:state, l:new_win_ids)
    endif
  endif

  if a:blur
    call flog#win#Restore(l:graph_win)
  endif

  return l:final_win.win_id
endfunction

function! flog#floggraph#side_win#OpenTmp(cmd, blur) abort
  return flog#floggraph#side_win#Open(a:cmd, a:blur, v:true)
endfunction
