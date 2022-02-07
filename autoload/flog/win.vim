vim9script

#
# This file contains functions for handling windows.
#

export def GetAllIds(): list<number>
  var windows = []
  for tab in gettabinfo()
    windows += tab.windows
  endfor
  return windows
enddef

export def Save(): list<any>
  return [win_getid(), bufnr(), winsaveview(), virtcol('.') virtcol('$')]
enddef

export def GetSavedId(saved_win: list<any>): number
  return saved_win[0]
enddef

export def GetSavedBufnr(saved_win: list<any>): number
  return saved_win[1]
enddef

export def GetSavedView(saved_win: list<any>): dict<any>
  return saved_win[2]
enddef

export def GetSavedVcol(saved_win: list<any>): number
  return saved_win[3]
enddef

export def GetSavedVcols(saved_win: list<any>): number
  return saved_win[4]
enddef

export def Is(saved_win: list<any>): bool
  return win_getid() == saved_win[0]
enddef

export def Restore(saved_win: list<any>): number
  const [win_id, bufnr, view, _, _] = saved_win

  silent! call win_gotoid(win_id)

  const new_win_id = win_getid()

  if Is(saved_win)
    winrestview(view)
    RestoreVcol(saved_win)
  endif

  return new_win_id
enddef

export def RestoreTopline(saved_win: list<any>): number
  const view = GetSavedView(saved_win)

  if view.topline == 1
    return -1
  endif
  
  const topline = view.topline - view.lnum + line('.')

  winrestview({ topline: topline })

  return topline
enddef

export def RestoreVcol(saved_win: list<any>): number
  var vcol = GetSavedVcol(saved_win)
  setcursorcharpos('.', vcol)
  return vcol
enddef
