vim9script

#
# This file contains functions for modifying options in "floggraph" buffers.
#

export def Toggle(name: string): bool
  flog#floggraph#buf#AssertFlogBuf()
  const opts = flog#state#GetBufState().opts

  const val = !opts[name]
  opts[name] = val

  flog#floggraph#buf#Update()

  return val
enddef

export def ToggleAll(): bool
  return Toggle('all')
enddef

export def ToggleBisect(): bool
  return Toggle('bisect')
enddef

export def ToggleMerges(): bool
  return Toggle('merges')
enddef

export def ToggleReflog(): bool
  return Toggle('reflog')
enddef

export def ToggleReverse(): bool
  return Toggle('reverse')
enddef

export def ToggleGraph(): bool
  return Toggle('graph')
enddef

export def TogglePatch(): bool
  return Toggle('patch')
enddef

export def CycleSort(): string
  flog#floggraph#buf#AssertFlogBuf()
  const opts = flog#state#GetBufState().opts

  const default_sort = opts.graph ? 'topo' : 'date'

  var sort = opts.sort
  if empty(sort)
    sort = default_sort
  endif

  const sort_type = flog#global_opts#GetSortType(sort)

  if empty(sort_type)
    sort = g:flog_sort_types[0].name
  else
    const sort_index = index(g:flog_sort_types, sort_type)

    if sort_index == len(g:flog_sort_types) - 1
      sort = g:flog_sort_types[0].name
    else
      sort = g:flog_sort_types[sort_index + 1].name
    endif
  endif

  opts.sort = sort

  flog#floggraph#buf#Update()

  return sort
enddef
