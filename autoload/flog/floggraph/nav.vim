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

  const lnum = get(state.commit_lines, hash, -1)
  if lnum < 0
    return [-1, -1]
  endif

  const col = get(state.commit_cols, hash, -1)
  if col < 0
    setcharpos('.', [bufnr(), lnum, 1, 1])
  else
    setcharpos('.', [bufnr(), lnum, col, col])
  endif

  return [lnum, col]
enddef

def flog#floggraph#nav#jump_to_commit_at_index(index: number): list<number>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const commit = get(state.commits, index, {})
  if empty(commit)
    return [-1, -1]
  endif

  return flog#floggraph#nav#jump_to_commit(commit.hash)
enddef

def flog#floggraph#nav#jump_to_mark(key: string): list<number>
  flog#floggraph#buf#assert_flog_buf()

  const commit = flog#floggraph#mark#get(key)
  if empty(commit)
    return {}
  endif

  const prev_line = line('.')
  const result = flog#floggraph#nav#jump_to_commit(commit.hash)
  flog#floggraph#mark#set_jump(prev_line)

  return result
enddef

def flog#floggraph#nav#next_commit(offset: number = 1): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  
  const commit = flog#floggraph#commit#get_next(offset)
  if !empty(commit)
    flog#floggraph#nav#jump_to_commit(commit.hash)
  endif

  return commit
enddef

def flog#floggraph#nav#prev_commit(offset: number = 1): dict<any>
  return flog#floggraph#nav#next_commit(-offset)
enddef

def flog#floggraph#nav#next_ref_commit(count: number = 1): number
  flog#floggraph#buf#assert_flog_buf()

  const [nrefs, commit] = flog#floggraph#commit#get_next_ref(count)

  if !empty(commit)
    call flog#floggraph#nav#jump_to_commit(commit.hash)
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
