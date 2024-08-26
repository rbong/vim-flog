"
" This file contains functions for handling options in "floggraph" buffers.
"

function! flog#floggraph#opts#Toggle(name) abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:opts = flog#state#GetBufState().opts

  let l:val = !l:opts[a:name]
  let l:opts[a:name] = l:val

  call flog#floggraph#buf#Update()

  return l:val
endfunction

function! flog#floggraph#opts#ToggleAll() abort
  return flog#floggraph#opts#Toggle('all')
endfunction

function! flog#floggraph#opts#ToggleBisect() abort
  return flog#floggraph#opts#Toggle('bisect')
endfunction

function! flog#floggraph#opts#ToggleFirstParent() abort
  return flog#floggraph#opts#Toggle('first_parent')
endfunction

function! flog#floggraph#opts#ToggleMerges() abort
  return flog#floggraph#opts#Toggle('merges')
endfunction

function! flog#floggraph#opts#ToggleReflog() abort
  return flog#floggraph#opts#Toggle('reflog')
endfunction

function! flog#floggraph#opts#ToggleReverse() abort
  return flog#floggraph#opts#Toggle('reverse')
endfunction

function! flog#floggraph#opts#ToggleGraph() abort
  return flog#floggraph#opts#Toggle('graph')
endfunction

function! flog#floggraph#opts#TogglePatch() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:opts = flog#state#GetBufState().opts

  let l:is_patch_implied = flog#opts#IsPatchImplied(l:opts)

  " Get current patch value
  let l:patch = l:opts.patch
  if l:patch == -1
    let l:patch = l:is_patch_implied
  endif

  " Set new patch value
  let l:patch = !l:patch
  if l:patch == l:is_patch_implied
    let l:patch = -1
  endif
  let l:opts.patch = l:patch

  call flog#floggraph#buf#Update()

  return l:opts.patch
endfunction

function! flog#floggraph#opts#CycleOrder() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:opts = flog#state#GetBufState().opts

  let l:default_order = l:opts.graph ? 'topo' : 'date'

  let l:order = l:opts.order
  if empty(l:order)
    let l:order = l:default_order
  endif

  let l:order_type = flog#global_opts#GetOrderType(l:order)

  if empty(l:order_type)
    let l:order = g:flog_order_types[0].name
  else
    let l:order_index = index(g:flog_order_types, l:order_type)

    if l:order_index == len(g:flog_order_types) - 1
      let l:order = g:flog_order_types[0].name
    else
      let l:order = g:flog_order_types[l:order_index + 1].name
    endif
  endif

  let l:opts.order = l:order

  call flog#floggraph#buf#Update()

  return l:order
endfunction

function! flog#floggraph#opts#ShouldAutoUpdate() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()
  let l:opts = flog#state#GetResolvedOpts(l:state)

  return l:opts.auto_update
endfunction
