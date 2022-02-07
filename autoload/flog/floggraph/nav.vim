vim9script

#
# This file contains functions for navigating in "floggraph" buffers.
#

export def JumpToCommit(hash: string): list<number>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  if empty(hash)
    return [-1, -1]
  endif

  const commit = get(state.commits_by_hash, hash, {})
  if empty(commit)
    return [-1, -1]
  endif

  const lnum = max([commit.line, 1])
  const col = max([commit.col, 1])

  setcursorcharpos(lnum, col)

  return [lnum, col]
enddef

export def JumpToMark(key: string): list<number>
  flog#floggraph#buf#AssertFlogBuf()

  const prev_line = line('.')
  const prev_commit = flog#floggraph#commit#GetAtLine(prev_line)

  const commit = flog#floggraph#mark#Get(key)
  if empty(commit)
    return [-1, -1]
  endif

  const result = JumpToCommit(commit.hash)

  if commit != prev_commit
    flog#floggraph#mark#SetJump(prev_line)
  endif

  return result
enddef

export def NextCommit(count: number = 1): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  
  const prev_line = line('.')

  const commit = flog#floggraph#commit#GetNext(count)

  if !empty(commit)
    JumpToCommit(commit.hash)
    flog#floggraph#mark#SetJump(prev_line)
  endif

  return commit
enddef

export def PrevCommit(count: number = 1): dict<any>
  return NextCommit(-count)
enddef

export def NextRefCommit(count: number = 1): number
  flog#floggraph#buf#AssertFlogBuf()

  const prev_line = line('.')

  const [nrefs, commit] = flog#floggraph#commit#GetNextRef(count)

  if !empty(commit)
    JumpToCommit(commit.hash)
    flog#floggraph#mark#SetJump(prev_line)
  endif

  return nrefs
enddef

export def PrevRefCommit(count: number = 1): number
  return NextRefCommit(-count)
enddef

export def SkipTo(skip: number): number
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  var skip_opt = string(skip)
  if skip_opt == '0'
    skip_opt = ''
  endif

  if state.opts.skip == skip_opt
    return skip
  endif

  state.opts.skip = skip_opt

  flog#floggraph#buf#Update()

  return skip
enddef

export def SkipAhead(count: number): number
  flog#floggraph#buf#AssertFlogBuf()
  const opts = flog#state#GetBufState().opts

  if empty(opts.max_count)
    return -1
  endif

  var skip = empty(opts.skip) ? 0 : str2nr(opts.skip)
  skip += str2nr(opts.max_count) * count
  if skip < 0
    skip = 0
  endif

  return SkipTo(skip)
enddef

export def SkipBack(count: number): number
  return SkipAhead(-count)
enddef

export def SetRevToCommitAtLine(line: any = '.'): string
  flog#floggraph#buf#AssertFlogBuf()
  var state = flog#state#GetBufState()

  const commit = flog#floggraph#commit#GetAtLine(line)

  if empty(commit)
    return ''
  endif

  const hash = commit.hash
  const rev = [hash]
  
  if state.opts.rev == rev
    return ''
  endif

  state.opts.skip = ''
  state.opts.rev = rev

  flog#floggraph#buf#Update()
  
  return hash
enddef

export def ClearRev(): bool
  flog#floggraph#buf#AssertFlogBuf()
  var state = flog#state#GetBufState()

  if empty(state.opts.rev)
    return false
  endif

  state.opts.rev = []
  flog#floggraph#buf#Update()

  return true
enddef

export def JumpToCommitStart(): number
  flog#floggraph#buf#AssertFlogBuf()

  const curr_col = virtcol('.')

  const commit = flog#floggraph#commit#GetAtLine('.')
  if empty(commit)
    return -1
  endif

  var new_col = commit.col
  if commit.line == line('.') && curr_col <= commit.col
    new_col = commit.format_col
  endif

  setcursorcharpos(commit.line, new_col)

  return new_col
enddef
