vim9script

#
# This file contains functions for modifying options in "floggraph" buffers.
#

import autoload 'flog/global_opts.vim'
import autoload 'flog/state.vim' as flog_state

import autoload 'flog/floggraph/buf.vim'

export def Toggle(name: string): bool
  buf.AssertFlogBuf()
  const opts = flog_state.GetBufState().opts

  const val = !opts[name]
  opts[name] = val

  buf.Update()

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

export def CycleOrder(): string
  buf.AssertFlogBuf()
  const opts = flog_state.GetBufState().opts

  const default_order = opts.graph ? 'topo' : 'date'

  var order = opts.order
  if empty(order)
    order = default_order
  endif

  const order_type = global_opts.GetOrderType(order)

  if empty(order_type)
    order = g:flog_order_types[0].name
  else
    const order_index = index(g:flog_order_types, order_type)

    if order_index == len(g:flog_order_types) - 1
      order = g:flog_order_types[0].name
    else
      order = g:flog_order_types[order_index + 1].name
    endif
  endif

  opts.order = order

  buf.Update()

  return order
enddef
