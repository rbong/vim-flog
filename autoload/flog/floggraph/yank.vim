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
