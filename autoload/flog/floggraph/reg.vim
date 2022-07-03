"
" This file contains functions for manipulating the register in "floggraph" buffers.
"

function! flog#floggraph#reg#YankHash(reg = '"', line = '.', count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if a:count < 1
    call setreg(a:reg, [], 'v')
    return 0
  endif

  let l:commit = flog#floggraph#commit#GetAtLine(a:line)
  if empty(l:commit)
    call setreg(a:reg, [], 'v')
    return 0
  endif

  let l:commit_index = index(l:state.commits, l:commit)

  let l:hashes = [l:commit.hash]
  let l:i = 1
  while l:i < a:count
    let l:commit = get(l:state.commits, l:commit_index + l:i, {})
    if empty(l:commit)
      break
    endif

    call add(l:hashes, l:commit.hash)

    let l:i += 1
  endwhile

  call setreg(a:reg, l:hashes, 'v')

  return l:i
endfunction

function! flog#floggraph#reg#YankHashRange(reg = '"', start_line = "'<", end_line = "'>") abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:start_commit = flog#floggraph#commit#GetAtLine(a:start_line)
  let l:end_commit = flog#floggraph#commit#GetAtLine(a:end_line)
  if empty(l:start_commit) || empty(l:end_commit)
    call setreg(a:reg, [])
    return 0
  endif

  let l:start_index = index(l:state.commits, l:start_commit)
  let l:end_index = index(l:state.commits, l:end_commit)
  if l:start_index < 0 || l:end_index < 0
    call setreg(a:reg, [])
    return 0
  endif

  return flog#floggraph#reg#YankHash(a:reg, a:start_line, l:end_index - l:start_index + 1)
endfunction
