vim9script

#
# This file contains functions for handling side windows in "floggraph" buffers.
#

def flog#floggraph#side_win#close_tmp(): list<number>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const prev_win = flog#win#save()

  for tmp_id in state.tmp_side_wins
    # Buffer is not open
    if win_id2tabwin(tmp_id) == [0, 0]
      continue
    endif

    # Buffer is open, close
    win_gotoid(tmp_id)
    silent! close!
  endfor

  flog#win#restore(prev_win)

  return flog#state#reset_tmp_side_wins(state)
enddef

def flog#floggraph#side_win#is_initialized(): bool
  return exists('b:flog_side_win_initialized')
enddef

def flog#floggraph#side_win#initialize(state: dict<any>, is_tmp: bool): number
  if !flog#state#has_buf_state()
    flog#state#set_buf_state(state)
  endif

  flog#deprecate#autocmd('FlogCmdBufferSetup', 'FlogSideWinSetup')
  flog#deprecate#autocmd('FlogTmpCmdBufferSetup', 'FlogTmpSideWinSetup')
  flog#deprecate#autocmd('FlogNonTmpCmdBufferSetup', 'FlogNonTmpSideWinSetup')

  silent! doautocmd User FlogSideWinSetup

  if is_tmp
    silent! doautocmd User FlogTmpSideWinSetup
  else
    silent! doautocmd User FlogNonTmpSideWinSetup
  endif

  b:flog_side_win_initialized = true

  return win_getid()
enddef

def flog#floggraph#side_win#open(cmd: string, keep_focus: bool, is_tmp: bool): number
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const graph_win = flog#win#save()
  const saved_win_ids = flog#win#get_all_ids()

  exec cmd
  const final_win = flog#win#save()

  var new_win_ids = flog#win#get_all_ids()
  new_win_ids = flog#list#exclude(new_win_ids, saved_win_ids)

  if !empty(new_win_ids)
    flog#win#restore(graph_win)

    if is_tmp
      flog#floggraph#side_win#close_tmp()
    endif

    for win_id in new_win_ids
      silent! call win_gotoid(win_id)
      if !flog#floggraph#side_win#is_initialized()
        flog#floggraph#side_win#initialize(state, is_tmp)
      endif
    endfor

    flog#win#restore(final_win)

    if is_tmp
      flog#state#set_tmp_side_wins(state, new_win_ids)
    endif
  endif

  if !keep_focus
    flog#win#restore(graph_win)
  endif

  return flog#win#get_saved_id(final_win)
enddef

def flog#floggraph#side_win#open_tmp(cmd: string, keep_focus: bool): number
  return flog#floggraph#side_win#open(cmd, keep_focus, true)
enddef
