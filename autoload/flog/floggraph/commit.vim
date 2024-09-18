"
" This file contains functions for handling commits in "floggraph" buffers.
"

function! flog#floggraph#commit#GetIndexAtLine(line = '.') abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:lnum = type(a:line) == v:t_number ? a:line : line(a:line)
  return get(l:state.line_commits, l:lnum - 1, -1)
endfunction

function! flog#floggraph#commit#GetAtLine(line = '.') abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit_index = flog#floggraph#commit#GetIndexAtLine(a:line)
  return get(l:state.commits, l:commit_index, {})
endfunction

function! flog#floggraph#commit#GetIndexByHash(hash) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()
  return get(l:state.commits_by_hash, a:hash, -1)
endfunction

function! flog#floggraph#commit#GetByHash(hash) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit_index = flog#floggraph#commit#GetIndexByHash(a:hash)
  return get(l:state.commits, l:commit_index, {})
endfunction

function! flog#floggraph#commit#GetByRef(ref) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:cmd = flog#git#GetCommand()
  let l:cmd += ['rev-parse', '--short ', flog#shell#Escape(a:ref)]

  let l:result = flog#shell#Run(l:cmd)
  if empty(l:result)
    return {}
  endif

  return flog#floggraph#commit#GetByHash(l:result[0])
endfunction

function! flog#floggraph#commit#GetNext(offset = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit_index = flog#floggraph#commit#GetIndexAtLine('.')
  if l:commit_index < 0 || l:commit_index + a:offset < 0
    return {}
  endif

  return get(l:state.commits, l:commit_index + a:offset, {})
endfunction

function! flog#floggraph#commit#GetPrev(offset = 1) abort
  return flog#floggraph#commit#GetNext(-a:offset)
endfunction

function! flog#floggraph#commit#GetNextRef(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if a:count == 0
    return [0, {}]
  endif

  let l:step = a:count > 0 ? 1 : -1

  let l:commits = l:state.commits
  let l:ncommits = len(l:commits)

  let l:ref_commit = {}
  let l:commit = flog#floggraph#commit#GetAtLine('.')

  let l:nrefs = 0
  let l:i = index(l:state.commits, l:commit) + l:step
  while l:i >= 0 && l:i < l:ncommits && l:nrefs != a:count
    let l:commit = l:commits[l:i]
    if !empty(l:commit.refs)
      let l:ref_commit = l:commit
      let l:nrefs += l:step
    endif

    let l:i += l:step
  endwhile

  return [l:nrefs, l:ref_commit]
endfunction

function! flog#floggraph#commit#GetPrevRef(count = 1) abort
  return flog#floggraph#commit#GetNext(-a:count)
endfunction

function! flog#floggraph#commit#GetChild(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if a:count == 0
    return [0, {}]
  endif

  let l:commits = l:state.commits
  let l:ncommits = len(l:commits)

  let l:child_commit = {}
  let l:commit = flog#floggraph#commit#GetAtLine('.')
  let l:commit_hash = l:commit.hash

  let l:nchildren = 0
  let l:i = index(l:state.commits, l:commit) - 1
  while l:i >= 0 && l:nchildren != a:count
    let l:commit = l:commits[l:i]
    if index(l:commit.parents, l:commit_hash) >= 0
      let l:child_commit = l:commit
      let l:nchildren += 1
    endif

    let l:i -= 1
  endwhile

  return [l:nchildren, l:child_commit]
endfunction

function! flog#floggraph#commit#RestoreOffset(saved_win, saved_commit) abort
  if empty(a:saved_commit)
    return [-1, -1]
  endif

  let l:saved_view = a:saved_win.view

  let l:line_offset = l:saved_view.lnum - a:saved_commit.line
  if l:line_offset < 0
    return [-1, -1]
  endif

  if l:line_offset == 0
    let l:new_col = 0
    let l:saved_col = a:saved_win.concealcol

    if l:saved_col == a:saved_commit.col
      let l:new_col = flog#floggraph#commit#GetAtLine('.').col
    elseif l:saved_col == a:saved_commit.format_col
      let l:new_col = flog#floggraph#commit#GetAtLine('.').format_col
    endif

    if l:new_col > 0
      call flog#win#SetConcealCol('.', l:new_col)
    endif

    return [0, l:new_col]
  endif

  let l:new_line = line('.') + l:line_offset

  let l:new_line_commit = flog#floggraph#commit#GetAtLine(l:new_line)
  if empty(l:new_line_commit) || l:new_line_commit.hash !=# a:saved_commit.hash
    return [-1, -1]
  endif

  call cursor(l:new_line, col('.'))

  return [l:line_offset, 0]
endfunction

function! flog#floggraph#commit#RestorePosition(saved_win, saved_commit) abort
  " Restore commit
  let l:commit_line = -1
  if !empty(a:saved_commit)
    let l:commit_line = flog#floggraph#nav#JumpToCommit(a:saved_commit.hash, v:false, v:false)[0]
  endif

  if l:commit_line < 0
    " If commit was not found, restore full window position
    call flog#win#Restore(a:saved_win)
    return {}
  endif

  " Try restoring the relative position
  let [l:line_offset, l:new_col] = flog#floggraph#commit#RestoreOffset(
        \ a:saved_win,
        \ a:saved_commit)

  " Restore parts of window position
  call flog#win#RestoreTopline(a:saved_win)
  if l:new_col == 0
    call flog#win#RestoreConcealCol(a:saved_win)
  endif

  return a:saved_commit
endfunction
