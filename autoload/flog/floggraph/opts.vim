vim9script

#
# This file contains functions for modifying options in "floggraph" buffers.
#

def flog#floggraph#opts#cycle_sort(): string
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  var sort = state.opts.sort

  if empty(sort)
    sort = g:flog_sort_types[0].name
  else
    const sort_type = flog#opts#get_sort_type(sort)
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
