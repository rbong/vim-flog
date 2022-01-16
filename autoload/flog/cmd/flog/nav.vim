vim9script

#
# This file contains functions for navigating the ":Flog" buffer.
#

def flog#cmd#flog#nav#get_commit_at_line(line: any = '.'): dict<any>
  flog#cmd#flog#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var lnum: number = type(line) == v:t_number ? line : line(line)

  return get(state.line_commits, lnum - 1, {})
enddef

def flog#cmd#flog#nav#get_next_commit(offset: number = 1): dict<any>
  flog#cmd#flog#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const commit = flog#cmd#flog#nav#get_commit_at_line('.')
  const commit_index = index(state.commits, commit)

  if commit_index < 0 || commit_index + offset < 0
    return {}
  endif

  return get(state.commits, commit_index + offset, {})
enddef

def flog#cmd#flog#nav#get_prev_commit(offset: number = 1): dict<any>
  return flog#cmd#flog#nav#get_next_commit(-offset)
enddef

def flog#cmd#flog#nav#jump_to_commit(hash: string): list<number>
  flog#cmd#flog#buf#assert_flog_buf()
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

def flog#cmd#flog#nav#next_commit(offset: number = 1): dict<any>
  flog#cmd#flog#buf#assert_flog_buf()
  
  const commit = flog#cmd#flog#nav#get_next_commit(offset)
  if !empty(commit)
    flog#cmd#flog#nav#jump_to_commit(commit.hash)
  endif

  return commit
enddef

def flog#cmd#flog#nav#prev_commit(offset: number = 1): dict<any>
  return flog#cmd#flog#nav#next_commit(-offset)
enddef
