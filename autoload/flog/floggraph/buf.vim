vim9script

#
# This file contains functions for creating and updating "floggraph" buffers.
#

import autoload 'flog/args.vim' as flog_args
import autoload 'flog/fugitive.vim'
import autoload 'flog/graph.vim' as flog_graph
import autoload 'flog/shell.vim'
import autoload 'flog/state.vim' as flog_state
import autoload 'flog/str.vim'
import autoload 'flog/win.vim'

import autoload 'flog/floggraph/commit.vim' as floggraph_commit
import autoload 'flog/floggraph/git.vim'
import autoload 'flog/floggraph/side_win.vim'

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

  var cmd = fugitive.GetGitCommand()
  cmd ..= ' status -s'
  const changes = len(shell.Run(cmd))

  if changes == 0
    b:flog_status_summary = 'No changes'
  elseif changes == 1
    b:flog_status_summary = '1 file changed'
  else
    b:flog_status_summary = string(changes) .. ' files changed'
  endif

  const head = fugitive.GetHead()

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
  if !empty(opts.order)
    name ..= ' [order=' .. opts.order .. ']'
  endif
  if !empty(opts.max_count)
    name ..= ' [max_count=' .. opts.max_count .. ']'
  endif
  if !empty(opts.search)
    name ..= ' [search=' .. str.Ellipsize(opts.search, 15) .. ']'
  endif
  if !empty(opts.patch_search)
    name ..= ' [patch_search=' .. str.Ellipsize(opts.patch_search, 15) .. ']'
  endif
  if !empty(opts.author)
    name ..= ' [author=' .. opts.author .. ']'
  endif
  if !empty(opts.limit)
    const [range, path] = flog_args.SplitGitLimitArg(opts.limit)
    name ..= ' [limit=' .. str.Ellipsize(range .. fnamemodify(path, ':t'), 15) .. ']'
  endif
  if len(opts.rev) == 1
    name ..= ' [rev=' .. str.Ellipsize(opts.rev[0], 15) .. ']'
  endif
  if len(opts.rev) > 1
    name ..= ' [rev=...]'
  endif
  if len(opts.path) == 1
    name ..= ' [path=' .. str.Ellipsize(fnamemodify(opts.path[0], ':t'), 15) .. ']'
  elseif len(opts.path) > 1
    name ..= ' [path=...]'
  endif

  return fnameescape(name)
enddef

export def Open(state: dict<any>): number
  const bufname = GetInitialName(state.instance_number)
  execute 'silent! ' .. state.opts.open_cmd .. bufname

  flog_state.SetBufState(state)

  var bufnr = bufnr()
  flog_state.SetGraphBufnr(state, bufnr)

  fugitive.TriggerDetection(flog_state.GetWorkdir(state))
  exec 'lcd ' .. fugitive.GetWorkdir()

  setlocal filetype=floggraph

  return bufnr
enddef

export def Update(): number
  AssertFlogBuf()
  const state = flog_state.GetBufState()
  const opts = flog_state.GetResolvedOpts(state)

  const graph_win = win.Save()

  if g:flog_enable_status
    UpdateStatus()
  endif

  const cmd = git.BuildLogCmd()
  flog_state.SetPrevLogCmd(state, cmd)
  const graph = flog_graph.Get(cmd)

  # Record previous commit
  const last_commit = floggraph_commit.GetAtLine('.')

  # Update graph
  flog_state.SetGraph(state, graph)
  SetContent(graph.output)

  # Restore commit position
  floggraph_commit.RestorePosition(graph_win, last_commit)

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
  const state = flog_state.GetBufState()

  const graph_win = win.Save()
  side_win.CloseTmp()

  win.Restore(graph_win)
  if win.Is(graph_win)
    silent! bdelete!
  endif

  return win.GetSavedId(graph_win)
enddef
