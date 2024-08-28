"
" This file contains functions for yanking text from "floggraph" buffers.
"

function! flog#floggraph#yank#Commits(reg = '"', line = '.', count = 1, expr = '[l:commit.hash]') abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if a:count < 1
    call setreg(a:reg, [], 'v')
    return 0
  endif

  let l:commit_index = flog#floggraph#commit#GetIndexAtLine(a:line)
  if l:commit_index < 0
    call setreg(a:reg, [], 'v')
    return 0
  endif

  let l:lines = []
  for l:i in range(a:count)
    let l:commit = get(l:state.commits, l:commit_index + l:i, {})
    if empty(l:commit)
      break
    endif

    let l:lines += eval(a:expr)
  endfor

  call setreg(a:reg, l:lines, 'v')

  return l:i
endfunction

function! flog#floggraph#yank#Hashes(reg = '"', line = '.', count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  return flog#floggraph#yank#Commits(a:reg, a:line, a:count, '[l:commit.hash]')
endfunction

function! flog#floggraph#yank#SanitizedText(reg = '"', line = '.', count = 1, include_graph = 0, skip_suffix = 0) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if a:count < 1
    call setreg(a:reg, [], 'v')
    return 0
  endif

  let l:default_collapsed = l:state.opts.default_collapsed
  let l:lines = []

  let l:start_lnum = type(a:line) == v:t_number ? a:line : line(a:line)

  for l:lnum in range(l:start_lnum, l:start_lnum + a:count - 1)
    let l:commit = flog#floggraph#commit#GetAtLine(l:lnum)
    if empty(l:commit)
      break
    endif

    let l:offset = l:lnum - l:commit.line
    let l:collapsed = get(l:state.collapsed_commits, l:commit.hash, l:default_collapsed)

    let l:len = l:commit.len
    if l:collapsed && l:len > 1
      let l:len = 2
    endif

    let l:line = ''
    if l:offset == 0
      " Add subject
      let l:line = l:commit.subject
    elseif l:offset < l:len
      " Add body
      if l:collapsed
        let l:line = l:commit.collapsed_body
      else
        let l:line = l:commit.body[l:offset - 1]
      endif
    else
      " Add suffix
      if a:skip_suffix
        continue
      elseif a:include_graph
        let l:line = l:commit.suffix[l:offset - l:commit.len]
      else
        let l:line = ''
      endif
    endif

    if l:offset < l:len
      " Remove graph
      if !a:include_graph
        let l:line = l:line[virtcol2col(0, l:lnum, l:commit.format_col) - 1 :]
      endif
      " Sanitize
      let l:line = substitute(l:line, '\e\[.', '', 'g')
    endif

    call add(l:lines, l:line)
  endfor

  call setreg(a:reg, l:lines, 'v')

  return a:count
endfunction

function! flog#floggraph#yank#GetCommitRangeCount(start_line = "'<", end_line = "'>") abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:start_index = flog#floggraph#commit#GetIndexAtLine(a:start_line)
  let l:end_index = flog#floggraph#commit#GetIndexAtLine(a:end_line)
  if l:start_index < 0 || l:end_index < 0
    return 0
  endif

  return l:end_index - l:start_index + 1
endfunction

function! flog#floggraph#yank#HashRange(reg = '"', start_line = "'<", end_line = "'>") abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:count = flog#floggraph#yank#GetCommitRangeCount(a:start_line, a:end_line)
  return flog#floggraph#yank#Hashes(a:reg, a:start_line, l:count)
endfunction

function! flog#floggraph#yank#SanitizedTextRange(reg = '"', start_line = "'<", end_line = "'>", include_graph = 0) abort
  let l:start_lnum = type(a:start_line) == v:t_number ? a:start_line : line(a:start_line)
  let l:end_lnum = type(a:end_line) == v:t_number ? a:end_line : line(a:end_line)
  let l:count = l:end_lnum - l:start_lnum + 1
  return flog#floggraph#yank#SanitizedText(a:reg, a:start_line, l:count, a:include_graph, !a:include_graph)
endfunction
