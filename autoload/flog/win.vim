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
  return [win_getid(), bufnr(), winsaveview(), virtcol('.') virtcol('$')]
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

def flog#win#get_saved_vcol(saved_win: list<any>): number
  return saved_win[3]
enddef

def flog#win#get_saved_vcols(saved_win: list<any>): number
  return saved_win[4]
enddef

def flog#win#is(saved_win: list<any>): bool
  return win_getid() == saved_win[0]
enddef

def flog#win#restore(saved_win: list<any>): number
  const [win_id, bufnr, view, _, _] = saved_win

  silent! call win_gotoid(win_id)

  const new_win_id = win_getid()

  if flog#win#is(saved_win)
    winrestview(view)
    flog#win#restore_vcol(saved_win)
  endif

  return new_win_id
enddef

def flog#win#restore_topline(saved_win: list<any>): number
  const view = flog#win#get_saved_view(saved_win)

  if view.topline == 1
    return -1
  endif
  
  const topline = view.topline - view.lnum + line('.')

  winrestview({ topline: topline })

  return topline
enddef

def flog#win#restore_vcol(saved_win: list<any>): number
  var vcol = flog#win#get_saved_vcol(saved_win)
  const vcols = flog#win#get_saved_vcols(saved_win)

  if vcol >= vcols - 1
    vcol = virtcol('$') - 1
  endif

  setcharpos('.', [bufnr(), line('.'), vcol, vcol])

  return vcol
enddef
