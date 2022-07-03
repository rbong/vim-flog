"
" This file contains functions for handling tabs.
"

function! flog#tab#GetInfo() abort
  return [tabpagenr(), tabpagenr('$')]
endfunction

function! flog#tab#DidCloseRight(tab_info) abort
  let [l:current_tab, l:last_tab] = a:tab_info
  return l:last_tab > tabpagenr('$')  && l:current_tab == tabpagenr()
endfunction
