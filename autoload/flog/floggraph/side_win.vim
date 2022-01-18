vim9script

#
# This file contains functions for handling side windows in "floggraph" buffers.
#

def flog#floggraph#side_win#close_tmp(): list<number>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const prev_win_id = win_getid()

  for tmp_id in state.tmp_side_wins
    # Buffer is not open
    if win_id2tabwin(tmp_id) == [0, 0]
      continue
    endif

    # Buffer is open, close
    win_gotoid(tmp_id)
    silent! close!
  endfor

  silent! call win_gotoid(prev_win_id)

  return flog#state#reset_tmp_side_wins(state)
enddef

def flog#floggraph#side_win#is_initialized(): bool
  return exists('b:flog_side_win_initialized')
enddef

def flog#floggraph#side_win#initialize(state: dict<any>, is_tmp: bool): number
  if !flog#state#has_buf_state()
    flog#state#set_buf_state(state)
  endif

  silent! doautocmd User FlogSideWinSetmp

  if is_tmp
    silent! doautocmd User FlogTmpSideWinSetmp
  else
    silent! doautocmd User FlogNonTmpSideWinSetmp
  endif

  b:flog_side_win_initialized = true

  return win_getid()
enddef

def flog#floggraph#side_win#open(cmd: string, keep_focus: bool, is_tmp: bool): number
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const graph_win_id = win_getid()
  const saved_win_ids = flog#win#get_all_ids()

  exec cmd
  const final_win_id = win_getid()

  var new_win_ids = flog#win#get_all_ids()
  new_win_ids = flog#list#exclude(new_win_ids, saved_win_ids)

  if !empty(new_win_ids)
    silent! call win_gotoid(graph_win_id)

    if is_tmp
      flog#floggraph#side_win#close_tmp()
    endif

    for win_id in new_win_ids
      silent! call win_gotoid(win_id)
      if !flog#floggraph#side_win#is_initialized()
        flog#floggraph#side_win#initialize(state, is_tmp)
      endif
    endfor

    silent! call win_gotoid(final_win_id)

    if is_tmp
      flog#state#set_tmp_side_wins(state, new_win_ids)
    endif
  endif

  if !keep_focus
    silent! call win_gotoid(graph_win_id)
  endif

  return final_win_id
enddef

def flog#floggraph#side_win#open_tmp(cmd: string, keep_focus: bool): number
  return flog#floggraph#side_win#open(cmd, keep_focus, true)
enddef
