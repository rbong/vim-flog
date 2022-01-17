vim9script

#
# This file contains functions for manipulating the register in "floggraph" buffers.
#

def flog#floggraph#reg#yank_hash(reg: string = '"', line: any = '.', count: number = 1): number
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  if count < 1
    setreg(reg, [])
    return 0
  endif

  var commit = flog#floggraph#nav#get_commit_at_line(line)
  if empty(commit)
    setreg(reg, [])
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

  setreg(reg, hashes)

  return i
enddef

def flog#floggraph#reg#yank_hash_range(reg: string = '"', start_line: any = "'<", end_line: any = "'>"): number
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var start_commit = flog#floggraph#nav#get_commit_at_line(start_line)
  var end_commit = flog#floggraph#nav#get_commit_at_line(end_line)
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

  return flog#floggraph#reg#yank_hash(reg, start_line, end_index - start_index + 1)
enddef
