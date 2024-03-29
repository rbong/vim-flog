"
" This file contains functions for collapsing commits in "floggraph" buffers.
"

function! flog#floggraph#collapse#Set(hash, collapse = 1, redraw = v:true) abort
  let l:state = flog#state#GetBufState()

  let l:collapsed_commits = l:state.collapsed_commits
  let l:collapse = a:collapse

  if l:collapse < 0
    if has_key(l:collapsed_commits, a:hash)
      let l:collapse = 0
    else
      let l:collapse = 1
    endif
  endif

  if l:collapse > 0
    let l:collapsed_commits[a:hash] = 1
  elseif has_key(l:collapsed_commits, a:hash)
    call remove(l:collapsed_commits, a:hash)
  endif

  if a:redraw
    call flog#floggraph#buf#Redraw()
  endif

  return has_key(l:collapsed_commits, a:hash)
endfunction

function! flog#floggraph#collapse#Expand(hash) abort
  return flog#floggraph#collapse#Set(a:hash, 0)
endfunction

function! flog#floggraph#collapse#Toggle(hash) abort
  return flog#floggraph#collapse#Set(a:hash, -1)
endfunction

function! flog#floggraph#collapse#AtLine(line = '.', collapse = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit = flog#floggraph#commit#GetAtLine(a:line)
  if empty(l:commit)
    return v:null
  endif

  return flog#floggraph#collapse#Set(l:commit.hash, a:collapse)
endfunction

function!flog#floggraph#collapse#ExpandAtLine(line = '.') abort
  return flog#floggraph#collapse#AtLine(a:line, 0)
endfunction

function!flog#floggraph#collapse#ToggleAtLine(line = '.') abort
  return flog#floggraph#collapse#AtLine(a:line, -1)
endfunction

function! flog#floggraph#collapse#Range(start_line, end_line, collapse = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit = flog#floggraph#commit#GetAtLine(a:start_line)
  if empty(l:commit)
    return v:null
  endif

  let l:end_commit = flog#floggraph#commit#GetAtLine(a:end_line)
  if empty(l:end_commit)
    return v:null
  endif

  let l:commits = l:state.commits
  let l:index = index(l:commits, l:commit)
  let l:end_hash = l:end_commit.hash

  if l:index < 0
    return v:null
  endif

  " Collapse first commit
  call flog#floggraph#collapse#Set(l:commit.hash, a:collapse, v:false)

  " Collapse remaining commits
  let l:last_index = len(l:commits) - 1
  while l:commit.hash != l:end_hash && l:index < l:last_index
    let l:index += 1
    let l:commit = l:commits[l:index]
    call flog#floggraph#collapse#Set(l:commit.hash, a:collapse, v:false)
  endwhile

  call flog#floggraph#buf#Redraw()

  return a:collapse
endfunction

function! flog#floggraph#collapse#ExpandRange(start_line, end_line) abort
  return flog#floggraph#collapse#Range(a:start_line, a:end_line, 0)
endfunction

function! flog#floggraph#collapse#ToggleRange(start_line, end_line) abort
  return flog#floggraph#collapse#Range(a:start_line, a:end_line, -1)
endfunction
