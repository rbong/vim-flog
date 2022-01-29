vim9script

#
# This file contains functions for navigating in "floggraph" buffers.
#

def flog#floggraph#nav#jump_to_commit(hash: string): list<number>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

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

def flog#floggraph#nav#jump_to_mark(key: string): list<number>
  flog#floggraph#buf#assert_flog_buf()

  const prev_line = line('.')
  const prev_commit = flog#floggraph#commit#get_at_line(prev_line)

  const commit = flog#floggraph#mark#get(key)
  if empty(commit)
    return [-1, -1]
  endif

  const result = flog#floggraph#nav#jump_to_commit(commit.hash)

  if commit != prev_commit
    flog#floggraph#mark#set_jump(prev_line)
  endif

  return result
enddef

def flog#floggraph#nav#next_commit(count: number = 1): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  
  const prev_line = line('.')

  const commit = flog#floggraph#commit#get_next(count)

  if !empty(commit)
    flog#floggraph#nav#jump_to_commit(commit.hash)
    flog#floggraph#mark#set_jump(prev_line)
  endif

  return commit
enddef

def flog#floggraph#nav#prev_commit(count: number = 1): dict<any>
  return flog#floggraph#nav#next_commit(-count)
enddef

def flog#floggraph#nav#next_ref_commit(count: number = 1): number
  flog#floggraph#buf#assert_flog_buf()

  const prev_line = line('.')

  const [nrefs, commit] = flog#floggraph#commit#get_next_ref(count)

  if !empty(commit)
    flog#floggraph#nav#jump_to_commit(commit.hash)
    flog#floggraph#mark#set_jump(prev_line)
  endif

  return nrefs
enddef

def flog#floggraph#nav#prev_ref_commit(count: number = 1): number
  return flog#floggraph#nav#next_ref_commit(-count)
enddef

def flog#floggraph#nav#skip_to(skip: number): number
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var skip_opt = string(skip)
  if skip_opt == '0'
    skip_opt = ''
  endif

  if state.opts.skip == skip_opt
    return skip
  endif

  state.opts.skip = skip_opt

  flog#floggraph#buf#update()

  return skip
enddef

def flog#floggraph#nav#skip_ahead(count: number): number
  flog#floggraph#buf#assert_flog_buf()
  const opts = flog#state#get_buf_state().opts

  if empty(opts.max_count)
    return -1
  endif

  var skip = empty(opts.skip) ? 0 : str2nr(opts.skip)
  skip += str2nr(opts.max_count) * count
  if skip < 0
    skip = 0
  endif

  return flog#floggraph#nav#skip_to(skip)
enddef

def flog#floggraph#nav#skip_back(count: number): number
  return flog#floggraph#nav#skip_ahead(-count)
enddef

def flog#floggraph#nav#set_rev(rev: string): string
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  if empty(rev)
    state.opts.rev = []
  else
    state.opts.skip = ''
    state.opts.rev = [rev]
  endif

  flog#floggraph#buf#update()

  return rev
enddef

def flog#floggraph#nav#jump_to_commit_start(): number
  flog#floggraph#buf#assert_flog_buf()

  const curr_col = virtcol('.')

  const commit = flog#floggraph#commit#get_at_line('.')
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
