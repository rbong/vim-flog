vim9script

#
# This file contains functions for working with commit marks in "floggraph" buffers.
#

def flog#floggraph#marks#set_internal(key: string, line: any): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()
  const commit = flog#floggraph#commit#get_at_line(line)
  return flog#state#set_internal_commit_mark(state, key, commit)
enddef

def flog#floggraph#marks#set(key: string, line: any): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()
  const commit = flog#floggraph#commit#get_at_line(line)
  return flog#state#set_commit_mark(state, key, commit)
enddef

def flog#floggraph#marks#set_jump(line: any = '.'): dict<any>
  return flog#floggraph#marks#set("'", line)
enddef

def flog#floggraph#marks#get(key: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  if key =~ '[<>]'
    return flog#floggraph#commit#get_at_line("'" .. key)
  endif

  if key == '@'
    return flog#floggraph#commit#get_by_ref('HEAD')
  endif
  if key =~ '[~^]'
    return flog#floggraph#commit#get_by_ref('HEAD~')
  endif

  if flog#state#is_cancel_commit_mark(key)
    throw g:flog_invalid_mark
  endif

  if !flog#state#has_commit_mark(state, key)
    return {}
  endif

  return flog#state#get_commit_mark(state, key)
enddef

def flog#floggraph#marks#jump(key: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()

  const commit = flog#floggraph#marks#get(key)
  if empty(commit)
    return {}
  endif

  const prev_line = line('.')
  flog#floggraph#nav#jump_to_commit(commit.hash)
  call flog#floggraph#marks#set_jump(prev_line)

  return commit
enddef
