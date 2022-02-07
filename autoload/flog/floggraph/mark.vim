vim9script

#
# This file contains functions for working with commit marks in "floggraph" buffers.
#

import autoload 'flog/state.vim' as flog_state

import autoload 'flog/floggraph/buf.vim'
import autoload 'flog/floggraph/commit.vim' as floggraph_commit

export def SetInternal(key: string, line: any): dict<any>
  buf.AssertFlogBuf()
  const state = flog_state.GetBufState()
  const commit = floggraph_commit.GetAtLine(line)
  return flog_state.SetInternalCommitMark(state, key, commit)
enddef

export def Set(key: string, line: any): dict<any>
  buf.AssertFlogBuf()
  const state = flog_state.GetBufState()
  const commit = floggraph_commit.GetAtLine(line)
  return flog_state.SetCommitMark(state, key, commit)
enddef

export def SetJump(line: any = '.'): dict<any>
  return Set("'", line)
enddef

export def Get(key: string): dict<any>
  buf.AssertFlogBuf()
  const state = flog_state.GetBufState()

  if key =~ '[<>]'
    return floggraph_commit.GetAtLine("'" .. key)
  endif

  if key == '@'
    return floggraph_commit.GetByRef('HEAD')
  endif
  if key =~ '[~^]'
    return floggraph_commit.GetByRef('HEAD~')
  endif

  if flog_state.IsCancelCommitMark(key)
    throw g:flog_invalid_mark
  endif

  if !flog_state.HasCommitMark(state, key)
    return {}
  endif

  return flog_state.GetCommitMark(state, key)
enddef

export def PrintAll(): dict<any>
  const marks = flog_state.GetBufState().commit_marks

  if empty(marks)
    echo 'No commit marks.'
    return marks
  endif

  for key in sort(keys(marks))
    echo '  ' .. key .. '  ' .. marks[key].hash
  endfor

  return marks
enddef
