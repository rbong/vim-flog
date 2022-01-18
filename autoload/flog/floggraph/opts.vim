vim9script

#
# This file contains functions for modifying options in "floggraph" buffers.
#

def flog#floggraph#opts#toggle(name: string): bool
  flog#floggraph#buf#assert_flog_buf()
  const opts = flog#state#get_buf_state().opts

  const val = !opts[name]
  opts[name] = val

  flog#floggraph#buf#update()

  return val
enddef

def flog#floggraph#opts#toggle_all(): bool
  return flog#floggraph#opts#toggle('all')
enddef

def flog#floggraph#opts#toggle_bisect(): bool
  return flog#floggraph#opts#toggle('bisect')
enddef

def flog#floggraph#opts#toggle_merges(): bool
  return flog#floggraph#opts#toggle('merges')
enddef

def flog#floggraph#opts#toggle_reflog(): bool
  return flog#floggraph#opts#toggle('reflog')
enddef

def flog#floggraph#opts#toggle_reverse(): bool
  return flog#floggraph#opts#toggle('reverse')
enddef

def flog#floggraph#opts#toggle_graph(): bool
  return flog#floggraph#opts#toggle('graph')
enddef

def flog#floggraph#opts#toggle_patch(): bool
  return flog#floggraph#opts#toggle('patch')
enddef

def flog#floggraph#opts#cycle_sort(): string
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var sort = state.opts.sort

  if empty(sort)
    sort = g:flog_sort_types[0].name
  else
    const sort_type = flog#global_opts#get_sort_type(sort)
    const sort_index = index(g:flog_sort_types, sort_type)

    if sort_index == len(g:flog_sort_types) - 1
      sort = g:flog_sort_types[0].name
    else
      sort = g:flog_sort_types[sort_index + 1].name
    endif
  endif

  state.opts.sort = sort

  flog#floggraph#buf#update()

  return sort
enddef
