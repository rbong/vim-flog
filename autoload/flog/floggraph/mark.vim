vim9script

#
# This file contains functions for working with commit marks in "floggraph" buffers.
#

export def SetInternal(key: string, line: any): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()
  const commit = flog#floggraph#commit#GetAtLine(line)
  return flog#state#SetInternalCommitMark(state, key, commit)
enddef

export def Set(key: string, line: any): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()
  const commit = flog#floggraph#commit#GetAtLine(line)
  return flog#state#SetCommitMark(state, key, commit)
enddef

export def SetJump(line: any = '.'): dict<any>
  return Set("'", line)
enddef

export def Get(key: string): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  if key =~ '[<>]'
    return flog#floggraph#commit#GetAtLine("'" .. key)
  endif

  if key == '@'
    return flog#floggraph#commit#GetByRef('HEAD')
  endif
  if key =~ '[~^]'
    return flog#floggraph#commit#GetByRef('HEAD~')
  endif

  if flog#state#IsCancelCommitMark(key)
    throw g:flog_invalid_mark
  endif

  if !flog#state#HasCommitMark(state, key)
    return {}
  endif

  return flog#state#GetCommitMark(state, key)
enddef

export def PrintAll(): dict<any>
  const marks = flog#state#GetBufState().commit_marks

  if empty(marks)
    echo 'No commit marks.'
    return marks
  endif

  for key in sort(keys(marks))
    echo '  ' .. key .. '  ' .. marks[key].hash
  endfor

  return marks
enddef
