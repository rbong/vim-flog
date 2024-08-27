"
" This file contains utility functions for working with format specifiers.
"

function! flog#format#ParseFormat(str, dict, cb) abort
  " Parse state
  let l:parens = v:false
  let l:item = ''

  " Parse character-by-character
  for l:char in split(a:str, '\zs')
    let l:item .= l:char

    if l:item ==# '%'
      " Item start
      continue
    elseif l:item ==# '%('
      " Paren start
      let l:parens = v:true
      continue
    elseif l:parens && l:char !=# ')'
      " Paren continue
      continue
    endif

    " Handle item
    let res = a:cb(a:dict, l:item, l:parens)

    if res > 0
      " Item found
      let l:item = ''
    elseif res < 0
      " Abort
      return
    endif

    " End parens
    if l:parens
      let l:parens = v:false
    endif
  endfor

  " Handle final item
  if l:item !=# ''
    call a:cb(a:dict, l:item, v:true)
  endif
endfunction
