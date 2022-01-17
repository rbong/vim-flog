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

def flog#cmd#flog#nav#get_commit_by_hash(hash: string): dict<any>
  flog#cmd#flog#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const lnum = get(state.commit_lines, hash, -1)
  if lnum < 0
    return {}
  endif

  return flog#cmd#flog#nav#get_commit_at_line(lnum)
enddef

def flog#cmd#flog#nav#get_commit_by_ref(ref: string): dict<any>
  flog#cmd#flog#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var cmd = flog#fugitive#get_git_command()
  cmd ..= ' rev-parse --short ' .. shellescape(ref)

  const result = flog#shell#run(cmd)
  if empty(result)
    return {}
  endif

  return flog#cmd#flog#nav#get_commit_by_hash(result[0])
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

def flog#cmd#flog#nav#jump_to_commit_at_index(index: number): list<number>
  flog#cmd#flog#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const commit = get(state.commits, index, {})
  if empty(commit)
    return [-1, -1]
  endif

  return flog#cmd#flog#nav#jump_to_commit(commit.hash)
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

def flog#cmd#flog#nav#get_next_ref_commit(count: number = 1): list<any>
  flog#cmd#flog#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  if count == 0
    return [0, {}]
  endif

  const step = count > 0 ? 1 : -1

  const commits = state.commits
  const ncommits = len(commits)

  var ref_commit = {}
  var commit = flog#cmd#flog#nav#get_commit_at_line('.')

  var nrefs = 0
  var i = index(state.commits, commit) + step
  while i >= 0 && i < ncommits && nrefs != count
    commit = commits[i]
    if !empty(commit.refs)
      ref_commit = commit
      nrefs += step
    endif

    i += step
  endwhile

  return [nrefs, ref_commit]
enddef

def flog#cmd#flog#nav#get_prev_ref_commit(count: number = 1): list<any>
  return flog#cmd#flog#nav#get_next_commit(-count)
enddef

def flog#cmd#flog#nav#next_ref_commit(count: number = 1): number
  flog#cmd#flog#buf#assert_flog_buf()

  const [nrefs, commit] = flog#cmd#flog#nav#get_next_ref_commit(count)

  if !empty(commit)
    call flog#cmd#flog#nav#jump_to_commit(commit.hash)
  endif

  return nrefs
enddef

def flog#cmd#flog#nav#prev_ref_commit(count: number = 1): number
  return flog#cmd#flog#nav#next_ref_commit(-count)
enddef
