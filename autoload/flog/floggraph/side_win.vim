vim9script

#
# This file contains functions for handling side windows in "floggraph" buffers.
#

import autoload 'flog/deprecate.vim'
import autoload 'flog/list.vim'
import autoload 'flog/state.vim' as flog_state
import autoload 'flog/win.vim'

import autoload 'flog/floggraph/buf.vim'

export def CloseTmp(): list<number>
  buf.AssertFlogBuf()
  const state = flog_state.GetBufState()

  const prev_win = win.Save()

  for tmp_id in state.tmp_side_wins
    # Buffer is not open
    if win_id2tabwin(tmp_id) == [0, 0]
      continue
    endif

    # Buffer is open, close
    win_gotoid(tmp_id)
    silent! close!
  endfor

  win.Restore(prev_win)

  return flog_state.ResetTmpSideWins(state)
enddef

export def IsInitialized(): bool
  return exists('b:flog_side_win_initialized')
enddef

export def Initialize(state: dict<any>, is_tmp: bool): number
  if !flog_state.HasBufState()
    flog_state.SetBufState(state)
  endif

  deprecate.Autocmd('FlogCmdBufferSetup', 'FlogSideWinSetup')
  deprecate.Autocmd('FlogTmpCmdBufferSetup', 'FlogTmpSideWinSetup')
  deprecate.Autocmd('FlogNonTmpCmdBufferSetup', 'FlogNonTmpSideWinSetup')

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
  buf.AssertFlogBuf()
  const state = flog_state.GetBufState()

  const graph_win = win.Save()
  const saved_win_ids = win.GetAllIds()

  exec cmd
  const final_win = win.Save()

  var new_win_ids: list<number> = win.GetAllIds()
  new_win_ids = list.Exclude(new_win_ids, saved_win_ids)

  if !empty(new_win_ids)
    win.Restore(graph_win)

    if is_tmp
      CloseTmp()
    endif

    for win_id in new_win_ids
      silent! call win_gotoid(win_id)
      if !IsInitialized()
        Initialize(state, is_tmp)
      endif
    endfor

    win.Restore(final_win)

    if is_tmp
      flog_state.SetTmpSideWins(state, new_win_ids)
    endif
  endif

  if !keep_focus
    win.Restore(graph_win)
  endif

  return win.GetSavedId(final_win)
enddef

export def OpenTmp(cmd: string, keep_focus: bool): number
  return Open(cmd, keep_focus, true)
enddef
