"
" This file contains functions for working with the commit jump list in
" "floggraph" buffers.
"

function! flog#floggraph#jumplist#Clear() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:state.commit_jumplist = []
  let l:state.commit_jumplist_index = -1
endfunction

function! flog#floggraph#jumplist#Stage(line) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:result = flog#floggraph#jumplist#Push(a:line)

  if l:result
    let l:state.commit_jumplist_index -= 1
  endif

  return l:result
endfunction

function! flog#floggraph#jumplist#Push(line) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:commit = flog#floggraph#commit#GetAtLine(a:line)

  if empty(l:commit)
    return v:false
  endif

  if l:state.commit_jumplist_index == 0
    let l:state.commit_jumplist = []
  elseif l:state.commit_jumplist_index > 0
    let l:current_hash = get(l:state.commit_jumplist, l:state.commit_jumplist_index - 1)

    if !empty(l:current_hash) && l:current_hash == l:commit.hash
      return v:false
    endif

    let l:state.commit_jumplist = l:state.commit_jumplist[:l:state.commit_jumplist_index - 1]
  endif

  let l:state.commit_jumplist += [l:commit.hash]
  let l:state.commit_jumplist_index = len(l:state.commit_jumplist)

  return v:true
endfunction

function! flog#floggraph#jumplist#Older(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if l:state.commit_jumplist_index < 0
    return v:null
  endif

  let l:state.commit_jumplist_index = max([l:state.commit_jumplist_index - a:count, 0])

  let l:hash = get(l:state.commit_jumplist, l:state.commit_jumplist_index)

  return l:hash
endfunction

function! flog#floggraph#jumplist#Newer(count = 1) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if l:state.commit_jumplist_index < 0
    return v:null
  endif

  let l:state.commit_jumplist_index = min([l:state.commit_jumplist_index + a:count, len(l:state.commit_jumplist) - 1])

  let l:hash = get(l:state.commit_jumplist, l:state.commit_jumplist_index)

  return l:hash
endfunction
