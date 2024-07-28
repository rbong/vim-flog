"
" This file contains functions for collapsing commits in "floggraph" buffers.
"

function! flog#floggraph#collapse#Set(hash, collapse = 1, redraw = v:true) abort
  let l:state = flog#state#GetBufState()

  let l:collapsed_commits = l:state.collapsed_commits
  let l:default_collapsed = l:state.opts.default_collapsed
  let l:collapse = a:collapse

  if l:collapse < 0
    if get(l:collapsed_commits, a:hash, l:default_collapsed)
      let l:collapse = 0
    else
      let l:collapse = 1
    endif
  endif

  let l:collapsed_commits[a:hash] = l:collapse

  if a:redraw
    call flog#floggraph#buf#Redraw()
  endif

  return l:collapse
endfunction

function! flog#floggraph#collapse#SetAll(collapse = v:true, redraw = v:true) abort
  let l:state = flog#state#GetBufState()

  let l:state.collapsed_commits = {}
  let l:state.opts.default_collapsed = a:collapse

  if a:redraw
    call flog#floggraph#buf#Redraw()
  endif

  return a:collapse
endfunction

function! flog#floggraph#collapse#Collapse(hash) abort
  return flog#floggraph#collapse#Set(a:hash, 1)
endfunction

function! flog#floggraph#collapse#CollapseAll() abort
  return flog#floggraph#collapse#SetAll(v:true)
endfunction

function! flog#floggraph#collapse#Expand(hash) abort
  return flog#floggraph#collapse#Set(a:hash, 0)
endfunction

function! flog#floggraph#collapse#ExpandAll() abort
  return flog#floggraph#collapse#SetAll(v:false)
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

function!flog#floggraph#collapse#CollapseAtLine(line = '.') abort
  return flog#floggraph#collapse#AtLine(a:line, 1)
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

function! flog#floggraph#collapse#CollapseRange(start_line, end_line) abort
  return flog#floggraph#collapse#Range(a:start_line, a:end_line, 1)
endfunction

function! flog#floggraph#collapse#ExpandRange(start_line, end_line) abort
  return flog#floggraph#collapse#Range(a:start_line, a:end_line, 0)
endfunction

function! flog#floggraph#collapse#ToggleRange(start_line, end_line) abort
  return flog#floggraph#collapse#Range(a:start_line, a:end_line, -1)
endfunction
