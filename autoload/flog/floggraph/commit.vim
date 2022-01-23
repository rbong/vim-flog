vim9script

#
# This file contains functions for handling commits in "floggraph" buffers.
#

def flog#floggraph#commit#get_at_line(line: any = '.'): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var lnum: number = type(line) == v:t_number ? line : line(line)

  return get(state.line_commits, lnum - 1, {})
enddef

def flog#floggraph#commit#get_by_hash(hash: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const commit = get(state.commits_by_hash, hash, {})
  if empty(commit)
    return {}
  endif

  return commit
enddef

def flog#floggraph#commit#get_by_ref(ref: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var cmd = flog#fugitive#get_git_command()
  cmd ..= ' rev-parse --short ' .. flog#shell#escape(ref)

  const result = flog#shell#run(cmd)
  if empty(result)
    return {}
  endif

  return flog#floggraph#commit#get_by_hash(result[0])
enddef

def flog#floggraph#commit#get_next(offset: number = 1): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const commit = flog#floggraph#commit#get_at_line('.')
  const commit_index = index(state.commits, commit)

  if commit_index < 0 || commit_index + offset < 0
    return {}
  endif

  return get(state.commits, commit_index + offset, {})
enddef

def flog#floggraph#commit#get_prev(offset: number = 1): dict<any>
  return flog#floggraph#commit#get_next(-offset)
enddef

def flog#floggraph#commit#get_next_ref(count: number = 1): list<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  if count == 0
    return [0, {}]
  endif

  const step = count > 0 ? 1 : -1

  const commits = state.commits
  const ncommits = len(commits)

  var ref_commit = {}
  var commit = flog#floggraph#commit#get_at_line('.')

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

def flog#floggraph#commit#get_prev_ref(count: number = 1): list<any>
  return flog#floggraph#commit#get_next(-count)
enddef
