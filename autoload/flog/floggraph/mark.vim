"
" This file contains functions for working with commit marks in "floggraph" buffers.
"

function! flog#floggraph#mark#SetInternal(key, line) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()
  let l:commit = flog#floggraph#commit#GetAtLine(a:line)
  return flog#state#SetInternalCommitMark(l:state, a:key, l:commit)
endfunction

function! flog#floggraph#mark#Set(key, line, stage_to_jumplist = v:true) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()
  let l:commit = flog#floggraph#commit#GetAtLine(a:line)

  if a:stage_to_jumplist
    call flog#floggraph#jumplist#Stage('.')
  endif

  return flog#state#SetCommitMark(l:state, a:key, l:commit)
endfunction

function! flog#floggraph#mark#SetJump(line = '.', stage_to_jumplist = v:true) abort
  return flog#floggraph#mark#Set("'", a:line, a:stage_to_jumplist)
endfunction

function! flog#floggraph#mark#Get(key) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  if a:key =~# '[<>]'
    return flog#floggraph#commit#GetAtLine("'" . a:key)
  endif

  if a:key ==# '@'
    return flog#floggraph#commit#GetByRef('HEAD')
  endif
  if a:key =~# '[~^]'
    return flog#floggraph#commit#GetByRef('HEAD~')
  endif

  if flog#state#IsCancelCommitMark(a:key)
    throw g:flog_invalid_mark
  endif

  if !flog#state#HasCommitMark(l:state, a:key)
    return {}
  endif

  return flog#state#GetCommitMark(l:state, a:key)
endfunction

function! flog#floggraph#mark#PrintAll() abort
  let l:marks = flog#state#GetBufState().commit_marks

  if empty(l:marks)
    echo 'No commit marks.'
    return l:marks
  endif

  for l:key in order(keys(l:marks))
    echo '  ' . l:key . '  ' . l:marks[l:key].hash
  endfor

  return l:marks
endfunction
