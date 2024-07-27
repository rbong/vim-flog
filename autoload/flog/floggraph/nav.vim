"
" This file contains functions for navigating in "floggraph" buffers.
"

function! flog#floggraph#nav#JumpToCommit(hash, set_jump_mark = v:true, push_to_jumplist = v:true) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if empty(a:hash)
    return [-1, -1]
  endif

  let l:commit_index = get(l:state.commits_by_hash, a:hash, -1)
  if l:commit_index < 0
    return [-1, -1]
  endif

  let l:commit = l:state.commits[l:commit_index]

  let l:prev_line = line('.')
  let l:prev_commit = flog#floggraph#commit#GetAtLine(l:prev_line)

  let l:line = max([l:commit.line, 1])
  let l:col = max([l:commit.col, 1])

  call flog#win#SetVcol(l:line, l:col)

  if a:push_to_jumplist
    call flog#floggraph#jumplist#Push(l:prev_line)
  endif
  if l:prev_commit.hash != l:commit.hash && a:set_jump_mark
    call flog#floggraph#mark#SetJump(l:prev_line, a:push_to_jumplist)
  endif

  return [l:line, l:col]
endfunction

function! flog#floggraph#nav#JumpToOlder(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()

  let l:hash = flog#floggraph#jumplist#Older(a:count)

  if empty(l:hash)
    return [-1, -1]
  endif

  let l:result = flog#floggraph#nav#JumpToCommit(l:hash, v:true, v:false)

  return l:result
endfunction

function! flog#floggraph#nav#JumpToNewer(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()

  let l:hash = flog#floggraph#jumplist#Newer(a:count)

  if empty(l:hash)
    return [-1, -1]
  endif

  let l:result = flog#floggraph#nav#JumpToCommit(l:hash, v:true, v:false)

  return l:result
endfunction

function! flog#floggraph#nav#JumpToParent(count) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit = flog#floggraph#commit#GetAtLine('.')
  if empty(l:commit)
    return [-1, -1]
  endif

  let l:parent_hash = get(l:commit.parents, a:count - 1)

  let l:result = flog#floggraph#nav#JumpToCommit(l:parent_hash)

  return l:result
endfunction

function! flog#floggraph#nav#JumpToChild(count) abort
  call flog#floggraph#buf#AssertFlogBuf()

  let [l:nchildren, l:commit] = flog#floggraph#commit#GetChild(a:count)
  if empty(l:commit)
    return [-1, -1]
  endif

  let l:result = flog#floggraph#nav#JumpToCommit(l:commit.hash)

  return l:result
endfunction

function! flog#floggraph#nav#JumpToMark(key) abort
  call flog#floggraph#buf#AssertFlogBuf()

  let l:commit = flog#floggraph#mark#Get(a:key)
  if empty(l:commit)
    return [-1, -1]
  endif

  let l:result = flog#floggraph#nav#JumpToCommit(l:commit.hash)

  return l:result
endfunction

function! flog#floggraph#nav#NextCommit(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  
  let l:prev_line = line('.')

  let l:commit = flog#floggraph#commit#GetNext(a:count)

  if !empty(l:commit)
    let l:result = flog#floggraph#nav#JumpToCommit(l:commit.hash)
  endif

  return l:commit
endfunction

function! flog#floggraph#nav#PrevCommit(count = 1) abort
  return flog#floggraph#nav#NextCommit(-a:count)
endfunction

function! flog#floggraph#nav#NextRefCommit(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()

  let l:prev_line = line('.')

  let [l:nrefs, l:commit] = flog#floggraph#commit#GetNextRef(a:count)

  if !empty(l:commit)
    call flog#floggraph#nav#JumpToCommit(l:commit.hash)
  endif

  return l:nrefs
endfunction

function! flog#floggraph#nav#PrevRefCommit(count = 1) abort
  return flog#floggraph#nav#NextRefCommit(-a:count)
endfunction

function! flog#floggraph#nav#SkipTo(skip) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:skip_opt = string(a:skip)
  if l:skip_opt ==# '0'
    let l:skip_opt = ''
  endif

  if l:state.opts.skip ==# l:skip_opt
    return a:skip
  endif

  let l:state.opts.skip = l:skip_opt

  call flog#floggraph#buf#Update()

  return a:skip
endfunction

function! flog#floggraph#nav#SkipAhead(count) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:opts = flog#state#GetBufState().opts

  if empty(l:opts.max_count)
    return -1
  endif

  let l:skip = empty(l:opts.skip) ? 0 : str2nr(l:opts.skip)
  let l:skip += str2nr(l:opts.max_count) * a:count
  if l:skip < 0
    let l:skip = 0
  endif

  return flog#floggraph#nav#SkipTo(l:skip)
endfunction

function! flog#floggraph#nav#SkipBack(count) abort
  return flog#floggraph#nav#SkipAhead(-a:count)
endfunction

function! flog#floggraph#nav#SetRevToCommitAtLine(line = '.') abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit = flog#floggraph#commit#GetAtLine(a:line)

  if empty(l:commit)
    return ''
  endif

  let l:hash = l:commit.hash
  let l:rev = [l:hash]
  
  if l:state.opts.rev ==# l:rev
    return ''
  endif

  let l:state.opts.skip = ''
  let l:state.opts.rev = l:rev

  call flog#floggraph#buf#Update()
  
  return l:hash
endfunction

function! flog#floggraph#nav#ClearRev() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if empty(l:state.opts.rev)
    return v:false
  endif

  let l:state.opts.rev = []
  call flog#floggraph#buf#Update()

  return v:true
endfunction

function! flog#floggraph#nav#JumpToCommitStart() abort
  call flog#floggraph#buf#AssertFlogBuf()

  let l:curr_col = flog#win#GetVcol('.')

  let l:commit = flog#floggraph#commit#GetAtLine('.')
  if empty(l:commit)
    return -1
  endif

  let l:new_col = l:commit.col
  if l:commit.line == line('.') && l:curr_col <= l:commit.col
    let l:new_col = l:commit.format_col
  endif

  call flog#win#SetVcol(l:commit.line, l:new_col)

  return l:new_col
endfunction
