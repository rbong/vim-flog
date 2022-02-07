vim9script

#
# This file contains functions for manipulating the register in "floggraph" buffers.
#

import autoload 'flog/state.vim' as flog_state

import autoload 'flog/floggraph/buf.vim'
import autoload 'flog/floggraph/commit.vim' as floggraph_commit

export def YankHash(reg: string = '"', line: any = '.', count: number = 1): number
  buf.AssertFlogBuf()
  const state = flog_state.GetBufState()

  if count < 1
    setreg(reg, [], 'v')
    return 0
  endif

  var commit = floggraph_commit.GetAtLine(line)
  if empty(commit)
    setreg(reg, [], 'v')
    return 0
  endif

  const commit_index = index(state.commits, commit)

  var hashes = [commit.hash]
  var i = 1
  while i < count
    commit = get(state.commits, commit_index + i, {})
    if empty(commit)
      break
    endif

    add(hashes, commit.hash)

    i += 1
  endwhile

  setreg(reg, hashes, 'v')

  return i
enddef

export def YankHashRange(reg: string = '"', start_line: any = "'<", end_line: any = "'>"): number
  buf.AssertFlogBuf()
  const state = flog_state.GetBufState()

  var start_commit = floggraph_commit.GetAtLine(start_line)
  var end_commit = floggraph_commit.GetAtLine(end_line)
  if empty(start_commit) || empty(end_commit)
    setreg(reg, [])
    return 0
  endif

  const start_index = index(state.commits, start_commit)
  const end_index = index(state.commits, end_commit)
  if start_index < 0 || end_index < 0
    setreg(reg, [])
    return 0
  endif

  return YankHash(reg, start_line, end_index - start_index + 1)
enddef
