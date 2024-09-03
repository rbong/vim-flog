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
  return {
        \ 'win_id': win_getid(),
        \ 'bufnr': bufnr(),
        \ 'view': winsaveview(),
        \ 'concealcol': flog#win#GetCols(line('.'), col('.'), -1).concealcol,
        \ }
endfunction

function! flog#win#Is(saved_win) abort
  return win_getid() == a:saved_win.win_id
endfunction

function! flog#win#Restore(saved_win) abort
  silent! call win_gotoid(a:saved_win.win_id)

  let l:new_win_id = win_getid()

  if flog#win#Is(a:saved_win)
    call winrestview(a:saved_win.view)
    call flog#win#RestoreConcealCol(a:saved_win)
  endif

  return l:new_win_id
endfunction

function! flog#win#RestoreTopline(saved_win) abort
  let l:view = a:saved_win.view

  if l:view.topline == 1
    return -1
  endif

  let l:topline = l:view.topline - l:view.lnum + line('.')

  call winrestview({ 'topline': l:topline })

  return l:topline
endfunction

function! flog#win#GetCols(lnum, target_col, target_concealcol) abort
  let l:line = getline(a:lnum)

  if len(l:line) == 0
    return { 'col': 0, 'virtcol': 0, 'concealcol': 0 }
  endif

  let l:col = 1
  let l:virtcol = 1
  let l:concealcol = 1
  let l:conceal_region = -1

  let l:end_col = col([a:lnum, '$'])
  while l:col <= l:end_col
    let [l:is_concealed, l:conceal_ch, l:new_conceal_region] = synconcealed(a:lnum, l:col)
    let l:is_conceal_region_changed = l:new_conceal_region != l:conceal_region

    let l:conceal_width = -1
    if l:is_concealed
      let l:conceal_width = l:is_conceal_region_changed ? strwidth(l:conceal_ch) : 0
    endif

    if a:target_col >= 0 && a:target_col <= l:col && l:conceal_width != 0
      break
    endif
    if a:target_concealcol >= 0 && a:target_concealcol <= l:concealcol && l:conceal_width != 0
      break
    endif

    let l:width = len(strcharpart(l:line, l:virtcol - 1, 1))
    if l:width <= 0
      break
    endif

    let l:col += l:width
    let l:virtcol += 1

    if !l:is_concealed
      let l:conceal_region = -1
      let l:concealcol += 1
    elseif l:is_conceal_region_changed
      let l:conceal_region = l:new_conceal_region
      let l:concealcol += l:conceal_width
    endif
  endwhile

  return { 'col': l:col, 'virtcol': l:virtcol, 'concealcol': l:concealcol }
endfunction

function! flog#win#GetConcealCol(expr) abort
  let l:col = type(a:expr) == v:t_number ? a:expr : col(a:expr)
  return flog#win#GetCols(line('.'), l:col, -1).concealcol
endfunction

function! flog#win#SetConcealCol(line, concealcol) abort
  let l:lnum = type(a:line) == v:t_number ? a:line : line(a:line)
  let l:col = flog#win#GetCols(l:lnum, -1, a:concealcol).col
  return cursor(l:lnum, l:col)
endfunction

function! flog#win#RestoreConcealCol(saved_win) abort
  call flog#win#SetConcealCol('.', a:saved_win.concealcol)
  return a:saved_win.concealcol
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
