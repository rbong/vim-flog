vim9script

#
# This file contains functions for handling side windows in "floggraph" buffers.
#

export def CloseTmp(): list<number>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  const prev_win = flog#win#Save()

  for tmp_id in state.tmp_side_wins
    # Buffer is not open
    if win_id2tabwin(tmp_id) == [0, 0]
      continue
    endif

    # Buffer is open, close
    win_gotoid(tmp_id)
    silent! close!
  endfor

  flog#win#Restore(prev_win)

  return flog#state#ResetTmpSideWins(state)
enddef

export def IsInitialized(): bool
  return exists('b:flog_side_win_initialized')
enddef

export def Initialize(state: dict<any>, is_tmp: bool): number
  if !flog#state#HasBufState()
    flog#state#SetBufState(state)
  endif

  flog#deprecate#Autocmd('FlogCmdBufferSetup', 'FlogSideWinSetup')
  flog#deprecate#Autocmd('FlogTmpCmdBufferSetup', 'FlogTmpSideWinSetup')
  flog#deprecate#Autocmd('FlogNonTmpCmdBufferSetup', 'FlogNonTmpSideWinSetup')

  if exists('#User#FlogSideWinSetup')
    doautocmd User FlogSideWinSetup
  endif

  if is_tmp
    if exists('#User#FlogTmpSideWinSetup')
      doautocmd User FlogTmpSideWinSetup
    endif
  else
    if exists('#User#FlogNonTmpSideWinSetup')
      doautocmd User FlogNonTmpSideWinSetup
    endif
  endif

  b:flog_side_win_initialized = true

  return win_getid()
enddef

export def Open(cmd: string, keep_focus: bool, is_tmp: bool): number
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  const graph_win = flog#win#Save()
  const saved_win_ids = flog#win#GetAllIds()

  exec cmd
  const final_win = flog#win#Save()

  var new_win_ids: list<number> = flog#win#GetAllIds()
  new_win_ids = flog#list#Exclude(new_win_ids, saved_win_ids)

  if !empty(new_win_ids)
    flog#win#Restore(graph_win)

    if is_tmp
      flog#floggraph#side_win#CloseTmp()
    endif

    for win_id in new_win_ids
      silent! call win_gotoid(win_id)
      if !flog#floggraph#side_win#IsInitialized()
        flog#floggraph#side_win#Initialize(state, is_tmp)
      endif
    endfor

    flog#win#Restore(final_win)

    if is_tmp
      flog#state#SetTmpSideWins(state, new_win_ids)
    endif
  endif

  if !keep_focus
    flog#win#Restore(graph_win)
  endif

  return flog#win#GetSavedId(final_win)
enddef

export def OpenTmp(cmd: string, keep_focus: bool): number
  return flog#floggraph#side_win#Open(cmd, keep_focus, true)
enddef
