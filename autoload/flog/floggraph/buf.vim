"
" This file contains functions for creating and updating "floggraph" buffers.
"

function! flog#floggraph#buf#IsFlogBuf() abort
  return &filetype ==# 'floggraph'
endfunction

function! flog#floggraph#buf#AssertFlogBuf() abort
  if !flog#floggraph#buf#IsFlogBuf()
    throw g:flog_not_a_flog_buffer
  endif
  return v:true
endfunction

function! flog#floggraph#buf#UpdateStatus() abort
  call flog#floggraph#buf#AssertFlogBuf()

  let cmd = flog#fugitive#GetGitCommand()
  let cmd .= ' status -s'
  let changes = len(flog#shell#Run(cmd))

  if changes == 0
    let b:flog_status_summary = 'No changes'
  elseif changes == 1
    let b:flog_status_summary = '1 file changed'
  else
    let b:flog_status_summary = string(changes) . ' files changed'
  endif

  let head = flog#fugitive#GetHead()

  if !empty(head)
    let b:flog_status_summary .= ' (' . head . ')'
  endif

  return b:flog_status_summary
endfunction

function! flog#floggraph#buf#GetInitialName(instance_number) abort
  return ' flog-' . string(a:instance_number) . ' [uninitialized]'
endfunction

function! flog#floggraph#buf#GetName(instance_number, opts) abort
  let name = 'flog-' . string(a:instance_number)

  if a:opts.all
    let name .= ' [all]'
  endif
  if a:opts.bisect
    let name .= ' [bisect]'
  endif
  if !a:opts.merges
    let name .= ' [no_merges]'
  endif
  if a:opts.reflog
    let name .= ' [reflog]'
  endif
  if a:opts.reverse
    let name .= ' [reverse]'
  endif
  if !a:opts.graph
    let name .= ' [no_graph]'
  endif
  if !a:opts.patch
    let name .= ' [no_patch]'
  endif
  if !empty(a:opts.skip)
    let name .= ' [skip=' . a:opts.skip . ']'
  endif
  if !empty(a:opts.order)
    let name .= ' [order=' . a:opts.order . ']'
  endif
  if !empty(a:opts.max_count)
    let name .= ' [max_count=' . a:opts.max_count . ']'
  endif
  if !empty(a:opts.search)
    let name .= ' [search=' . flog#str#Ellipsize(a:opts.search, 15) . ']'
  endif
  if !empty(a:opts.patch_search)
    let name .= ' [patch_search=' . flog#str#Ellipsize(a:opts.patch_search, 15) . ']'
  endif
  if !empty(a:opts.author)
    let name .= ' [author=' . a:opts.author . ']'
  endif
  if !empty(a:opts.limit)
    let [range, path] = flog#args#SplitGitLimitArg(a:opts.limit)
    let name .= ' [limit=' . flog#str#Ellipsize(range . fnamemodify(path, ':t'), 15) . ']'
  endif
  if len(a:opts.rev) == 1
    let name .= ' [rev=' . flog#str#Ellipsize(a:opts.rev[0], 15) . ']'
  endif
  if len(a:opts.rev) > 1
    let name .= ' [rev=...]'
  endif
  if len(a:opts.path) == 1
    let name .= ' [path=' . flog#str#Ellipsize(fnamemodify(a:opts.path[0], ':t'), 15) . ']'
  elseif len(a:opts.path) > 1
    let name .= ' [path=...]'
  endif

  return fnameescape(name)
endfunction

function! flog#floggraph#buf#Open(state) abort
  let bufname = flog#floggraph#buf#GetInitialName(a:state.instance_number)
  execute 'silent! ' . a:state.opts.open_cmd . bufname

  call flog#state#SetBufState(a:state)

  let bufnr = bufnr()
  call flog#state#SetGraphBufnr(a:state, bufnr)

  call flog#fugitive#TriggerDetection(flog#state#GetWorkdir(a:state))
  exec 'lcd ' . flog#fugitive#GetWorkdir()

  setlocal filetype=floggraph

  return bufnr
endfunction

function! flog#floggraph#buf#Update() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let state = flog#state#GetBufState()
  let opts = flog#state#GetResolvedOpts(state)

  let graph_win = flog#win#Save()

  if g:flog_enable_status
    call flog#floggraph#buf#UpdateStatus()
  endif

  let cmd = flog#floggraph#git#BuildLogCmd()
  call flog#state#SetPrevLogCmd(state, cmd)
  if has('nvim')
    let graph = flog#graph#nvim#Get(cmd)
  else
    let graph = flog#graph#vim#Get(cmd)
  end

  " Record previous commit
  let last_commit = flog#floggraph#commit#GetAtLine('.')

  " Update graph
  call flog#state#SetGraph(state, graph)
  call flog#floggraph#buf#SetContent(graph.output)

  " Restore commit position
  call flog#floggraph#commit#RestorePosition(graph_win, last_commit)

  silent! exec 'file ' . flog#floggraph#buf#GetName(state.instance_number, opts)

  if exists('#User#FlogUpdate')
    doautocmd User FlogUpdate
  endif

  return state.graph_bufnr
endfunction

function! flog#floggraph#buf#FinishUpdateHook(bufnr) abort
  if bufnr() != a:bufnr
    return -1
  endif

  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' . string(a:bufnr) . '>'
  augroup END

  call flog#floggraph#buf#Update()

  return a:bufnr
endfunction

function! flog#floggraph#buf#InitUpdateHook(bufnr) abort
  let buf = string(a:bufnr)

  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' . buf . '>'
    if exists('##SafeState')
      exec 'autocmd SafeState <buffer=' . buf . '> call flog#floggraph#buf#FinishUpdateHook(' . buf . ')'
    else
      exec 'autocmd WinEnter <buffer=' . buf . '> call flog#floggraph#buf#FinishUpdateHook(' . buf . ')'
    endif
  augroup END

  return a:bufnr
endfunction

function! flog#floggraph#buf#SetContent(content) abort
  call flog#floggraph#buf#AssertFlogBuf()

  setlocal modifiable noreadonly
  silent! 1,$ delete
  call setline(1, a:content)
  setlocal nomodifiable readonly

  return a:content
endfunction

function! flog#floggraph#buf#Close() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let state = flog#state#GetBufState()

  let graph_win = flog#win#Save()
  call flog#floggraph#side_win#CloseTmp()

  call flog#win#Restore(graph_win)
  if flog#win#Is(graph_win)
    let l:tab_info = flog#tab#GetInfo()
    silent! bdelete!
    if flog#tab#DidCloseRight(l:tab_info)
      tabprev
    end
  endif

  return flog#win#GetSavedId(graph_win)
endfunction
