vim9script

#
# This file contains functions for creating and updating "floggraph" buffers.
#

export def IsFlogBuf(): bool
  return &filetype == 'floggraph'
enddef

export def AssertFlogBuf(): bool
  if !IsFlogBuf()
    throw g:flog_not_a_flog_buffer
  endif
  return true
enddef

export def UpdateStatus(): string
  AssertFlogBuf()

  var cmd = flog#fugitive#GetGitCommand()
  cmd ..= ' status -s'
  const changes = len(flog#shell#Run(cmd))

  if changes == 0
    b:flog_status_summary = 'No changes'
  elseif changes == 1
    b:flog_status_summary = '1 file changed'
  else
    b:flog_status_summary = string(changes) .. ' files changed'
  endif

  const head = flog#fugitive#GetHead()

  if !empty(head)
    b:flog_status_summary ..= ' (' .. head .. ')'
  endif

  return b:flog_status_summary
enddef

export def GetInitialName(instance_number: number): string
  return ' flog-' .. string(instance_number) .. ' [uninitialized]'
enddef

export def GetName(instance_number: number, opts: dict<any>): string
  var name = 'flog-' .. string(instance_number)

  if opts.all
    name ..= ' [all]'
  endif
  if opts.bisect
    name ..= ' [bisect]'
  endif
  if !opts.merges
    name ..= ' [no_merges]'
  endif
  if opts.reflog
    name ..= ' [reflog]'
  endif
  if opts.reverse
    name ..= ' [reverse]'
  endif
  if !opts.graph
    name ..= ' [no_graph]'
  endif
  if !opts.patch
    name ..= ' [no_patch]'
  endif
  if !empty(opts.skip)
    name ..= ' [skip=' .. opts.skip .. ']'
  endif
  if !empty(opts.sort)
    name ..= ' [sort=' .. opts.sort .. ']'
  endif
  if !empty(opts.max_count)
    name ..= ' [max_count=' .. opts.max_count .. ']'
  endif
  if !empty(opts.search)
    name ..= ' [search=' .. flog#str#Ellipsize(opts.search, 15) .. ']'
  endif
  if !empty(opts.patch_search)
    name ..= ' [patch_search=' .. flog#str#Ellipsize(opts.patch_search, 15) .. ']'
  endif
  if !empty(opts.author)
    name ..= ' [author=' .. opts.author .. ']'
  endif
  if !empty(opts.limit)
    const [range, path] = flog#args#SplitGitLimitArg(opts.limit)
    name ..= ' [limit=' .. flog#str#Ellipsize(range .. fnamemodify(path, ':t'), 15) .. ']'
  endif
  if len(opts.rev) == 1
    name ..= ' [rev=' .. flog#str#Ellipsize(opts.rev[0], 15) .. ']'
  endif
  if len(opts.rev) > 1
    name ..= ' [rev=...]'
  endif
  if len(opts.path) == 1
    name ..= ' [path=' .. flog#str#Ellipsize(fnamemodify(opts.path[0], ':t'), 15) .. ']'
  elseif len(opts.path) > 1
    name ..= ' [path=...]'
  endif

  return fnameescape(name)
enddef

export def Open(state: dict<any>): number
  const bufname = GetInitialName(state.instance_number)
  execute 'silent! ' .. state.opts.open_cmd .. bufname

  flog#state#SetBufState(state)

  var bufnr = bufnr()
  flog#state#SetGraphBufnr(state, bufnr)

  flog#fugitive#TriggerDetection(flog#state#GetFugitiveWorkdir(state))
  exec 'lcd ' .. flog#fugitive#GetWorkdir()

  setlocal filetype=floggraph

  return bufnr
enddef

export def Update(): number
  AssertFlogBuf()
  const state = flog#state#GetBufState()
  const opts = flog#state#GetResolvedOpts(state)

  const graph_win = flog#win#Save()

  if g:flog_enable_status
    UpdateStatus()
  endif

  const cmd = flog#floggraph#git#BuildLogCmd()
  flog#state#SetPrevLogCmd(state, cmd)
  const graph = flog#lua#GetGraph(cmd)

  # Record previous commit
  const last_commit = flog#floggraph#commit#GetAtLine('.')

  # Update graph
  flog#state#SetGraph(state, graph)
  SetContent(graph.output)

  # Restore commit position
  flog#floggraph#commit#RestorePosition(graph_win, last_commit)

  silent! exec 'file ' .. GetName(state.instance_number, opts)

  if exists('#User#FlogUpdate')
    doautocmd User FlogUpdate
  endif

  return state.graph_bufnr
enddef

export def FinishUpdateHook(bufnr: number): number
  if bufnr() != bufnr
    return -1
  endif

  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' .. string(bufnr) .. '>'
  augroup END

  Update()

  return bufnr
enddef

export def InitUpdateHook(bufnr: number): number
  const buf = string(bufnr)

  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' .. buf .. '>'
    if exists('##SafeState')
      exec 'autocmd SafeState <buffer=' .. buf .. '> call flog#floggraph#buf#FinishUpdateHook(' .. buf .. ')'
    else
      exec 'autocmd WinEnter <buffer=' .. buf .. '> call flog#floggraph#buf#FinishUpdateHook(' .. buf .. ')'
    endif
  augroup END

  return bufnr
enddef

export def SetContent(content: list<string>): list<string>
  AssertFlogBuf()

  setlocal modifiable noreadonly
  silent! :1,$ delete
  setline(1, content)
  setlocal nomodifiable readonly

  return content
enddef

export def Close(): number
  AssertFlogBuf()
  const state = flog#state#GetBufState()

  const graph_win = flog#win#Save()
  flog#floggraph#side_win#CloseTmp()

  flog#win#Restore(graph_win)
  if flog#win#Is(graph_win)
    silent! bdelete!
  endif

  return flog#win#GetSavedId(graph_win)
enddef
