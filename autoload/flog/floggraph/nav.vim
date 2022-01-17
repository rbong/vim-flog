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
