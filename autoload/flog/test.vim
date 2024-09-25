"
" This file contains utils only for use in tests.
"

function! flog#test#Assert(cmd) abort
  if !eval(a:cmd)
    echoerr a:cmd
  endif
endfunction

function! flog#test#ShowNvimBufHl() abort
  " Get all highlight group extmarks
  let l:line_hl_groups = {}
  let l:col_fix = v:null
  for [l:id, l:row, l:start_col, l:details] in nvim_buf_get_extmarks(
        \ 0, -1, 0, -1, { 'details': 1, 'type': 'highlight' })
    if !has_key(l:line_hl_groups, l:row)
      let l:line_hl_groups[l:row] = {}
    endif
    let l:hl_groups = l:line_hl_groups[l:row]

    let l:start_virtcol = virtcol([l:row + 1, l:start_col + 1])
    let l:end_virtcol = virtcol([l:row + 1, l:details.end_col])

    for l:virtcol in range(l:start_virtcol, l:end_virtcol)
      let l:hl_groups[l:virtcol - 1] = l:details.hl_group
    endfor
  endfor

  " Build output
  let l:output = []
  for l:row in range(line('$'))
    let l:line = getline(l:row + 1)
    if l:line ==# ''
      call add(l:output, '')
      continue
    endif

    let l:out_line = ''
    let l:hl_groups = get(l:line_hl_groups, l:row, {})
    let l:hl_group = 'NONE'

    for l:byteidx in range(virtcol([l:row + 1, '$']) - 1)
      let l:new_hl_group = get(l:hl_groups, l:byteidx, '')
      let l:char = strcharpart(l:line, l:byteidx, 1)

      if l:char !=# ' ' && l:new_hl_group !=# l:hl_group
        let l:hl_group = l:new_hl_group
        let l:out_line .= '(' . l:hl_group . ')'
      endif

      let l:out_line .= l:char
    endfor

    call add(l:output, l:out_line)
  endfor

  " Set output buffer
  enew
  setlocal buftype=nofile
  call setline(1, l:output)
endfunction
