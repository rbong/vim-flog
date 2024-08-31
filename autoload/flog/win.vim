"
" This file contains functions for handling windows.
"

function! flog#win#GetAllIds() abort
  let l:windows = []
  for l:tab in gettabinfo()
    let l:windows += l:tab.windows
  endfor
  return l:windows
endfunction

function! flog#win#Save() abort
  return [win_getid(), bufnr(), winsaveview(), flog#win#GetVcol('.'), flog#win#GetVcol('$')]
endfunction

function! flog#win#GetSavedId(saved_win) abort
  return a:saved_win[0]
endfunction

function! flog#win#GetSavedBufnr(saved_win) abort
  return a:saved_win[1]
endfunction

function! flog#win#GetSavedView(saved_win) abort
  return a:saved_win[2]
endfunction

function! flog#win#GetSavedVcol(saved_win) abort
  return a:saved_win[3]
endfunction

function! flog#win#GetSavedVcols(saved_win) abort
  return a:saved_win[4]
endfunction

function! flog#win#Is(saved_win) abort
  return win_getid() == a:saved_win[0]
endfunction

function! flog#win#Restore(saved_win) abort
  let [l:win_id, l:bufnr, l:view, _, _] = a:saved_win

  silent! call win_gotoid(l:win_id)

  let l:new_win_id = win_getid()

  if flog#win#Is(a:saved_win)
    call winrestview(l:view)
    call flog#win#RestoreVcol(a:saved_win)
  endif

  return l:new_win_id
endfunction

function! flog#win#RestoreTopline(saved_win) abort
  let l:view = flog#win#GetSavedView(a:saved_win)

  if l:view.topline == 1
    return -1
  endif

  let l:topline = l:view.topline - l:view.lnum + line('.')

  call winrestview({ 'topline': l:topline })

  return l:topline
endfunction

function! flog#win#GetVcol(expr) abort
  return virtcol(a:expr)
endfunction

function! flog#win#SetVcol(line, vcol) abort
  if exists('*setcursorcharpos')
    return setcursorcharpos(a:line, a:vcol)
  endif

  let l:line = a:line
  if type(a:line) == v:t_string
    let l:line = line(a:line)
  endif

  return cursor(a:line, virtcol2col(win_getid(), l:line, a:vcol))
endfunction

function! flog#win#RestoreVcol(saved_win) abort
  let l:vcol = flog#win#GetSavedVcol(a:saved_win)
  call flog#win#SetVcol('.', l:vcol)
  return l:vcol
endfunction

function! flog#win#SaveSizes(windows) abort
  let l:sizes = {}
  for l:window in a:windows
    let l:tabwin = win_id2tabwin(l:window)
    if l:tabwin == [0, 0]
      continue
    endif

    let l:sizes[l:window] = [
          \ winwidth(l:window),
          \ winheight(l:window),
          \ gettabwinvar(l:tabwin[0], l:tabwin[1], '&winfixwidth'),
          \ gettabwinvar(l:tabwin[0], l:tabwin[1], '&winfixheight')]
  endfor
  return sizes
endfunction

function! flog#win#IsTabEmpty() abort
  return winnr('$') == 1
        \ && line('$') == 1
        \ && !&modified
        \ && &filetype ==# ''
        \ && &buftype ==# ''
        \ && getline(1) ==# ''
        \ && bufname() ==# ''
endfunction
