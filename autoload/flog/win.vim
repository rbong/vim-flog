vim9script

#
# This file contains functions for handling windows.
#

def flog#win#get_all_ids(): list<number>
  var windows = []
  for tab in gettabinfo()
    windows += tab.windows
  endfor
  return windows
enddef

def flog#win#save(): list<any>
  return [win_getid(), bufnr(), winsaveview()]
enddef

def flog#win#get_saved_id(saved_win: list<any>): number
  return saved_win[0]
enddef

def flog#win#get_saved_bufnr(saved_win: list<any>): number
  return saved_win[1]
enddef

def flog#win#get_saved_view(saved_win: list<any>): dict<any>
  return saved_win[2]
enddef

def flog#win#is(saved_win: list<any>): bool
  return win_getid() == saved_win[0]
enddef

def flog#win#restore(saved_win: list<any>): number
  const [win_id, bufnr, view] = saved_win

  silent! call win_gotoid(win_id)

  const new_win_id = win_getid()

  if flog#win#is(saved_win)
    winrestview(view)
  endif

  return new_win_id
enddef

def flog#win#restore_topline(saved_win: list<any>): number
  const view = flog#win#get_saved_view(saved_win)
  
  const topline = view.topline - view.lnum + line('.')

  winrestview({ topline: topline })

  return topline
enddef

def flog#win#restore_col(saved_win: list<any>): number
  const view = flog#win#get_saved_view(saved_win)

  winrestview({
    col: view.col,
    coladd: view.coladd,
    curswant: view.curswant,
    leftcol: view.leftcol,
    skipcall: view.skipcol,
    })

  return view.col
enddef
