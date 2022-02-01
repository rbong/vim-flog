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

def flog#floggraph#commit#restore_offset(saved_win: list<any>, saved_commit: dict<any>): list<number>
  if empty(saved_commit)
    return [-1, -1]
  endif

  const saved_view = flog#win#get_saved_view(saved_win)

  const line_offset = saved_view.lnum - saved_commit.line
  if line_offset < 0
    return [-1, -1]
  endif

  if line_offset == 0
    var new_col = 0
    const saved_vcol = flog#win#get_saved_vcol(saved_win)

    if saved_vcol == saved_commit.col
      new_col = flog#floggraph#commit#get_at_line('.').col
    elseif saved_vcol == saved_commit.format_col
      new_col = flog#floggraph#commit#get_at_line('.').format_col
    endif

    if new_col > 0
      setcursorcharpos('.', new_col)
    endif

    return [0, new_col]
  endif

  const new_line = line('.') + line_offset

  const new_line_commit = flog#floggraph#commit#get_at_line(new_line)
  if empty(new_line_commit) || new_line_commit.hash != saved_commit.hash
    return [-1, -1]
  endif

  cursor(new_line, col('.'))

  return [line_offset, 0]
enddef

def flog#floggraph#commit#restore_position(saved_win: list<any>, saved_commit: dict<any>): dict<any>
  # Restore commit
  var commit_line = -1
  if !empty(saved_commit)
    commit_line = flog#floggraph#nav#jump_to_commit(saved_commit.hash)[0]
  endif

  if commit_line < 0
    # If commit was not found, restore full window position
    flog#win#restore(saved_win)
    return {}
  endif

  # Try restoring the relative position
  const [line_offset, new_col] = flog#floggraph#commit#restore_offset(
    saved_win,
    saved_commit)

  # Restore parts of window position
  flog#win#restore_topline(saved_win)
  if new_col == 0
    flog#win#restore_vcol(saved_win)
  endif

  return saved_commit
enddef
