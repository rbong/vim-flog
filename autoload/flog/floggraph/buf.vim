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

  let l:cmd = flog#git#GetCommand(['status', '-s'])
  let l:changes = len(flog#shell#Run(l:cmd))

  if l:changes == 0
    let b:flog_status_summary = 'No changes'
  elseif l:changes == 1
    let b:flog_status_summary = '1 file changed'
  else
    let b:flog_status_summary = string(l:changes) . ' files changed'
  endif

  let l:head = flog#git#GetHeadRef()

  if !empty(l:head)
    let b:flog_status_summary .= ' (' . l:head . ')'
  endif

  return b:flog_status_summary
endfunction

function! flog#floggraph#buf#GetInitialName(instance_number) abort
  return ' flog-' . string(a:instance_number) . ' [uninitialized]'
endfunction

function! flog#floggraph#buf#GetName(instance_number, opts) abort
  let l:name = 'flog-' . string(a:instance_number)
  let l:is_patch_implied = flog#opts#IsPatchImplied(a:opts)

  if a:opts.all
    let l:name .= ' [all]'
  endif
  if a:opts.bisect
    let l:name .= ' [bisect]'
  endif
  if a:opts.first_parent
    let l:name .= ' [first_parent]'
  endif
  if !a:opts.merges
    let l:name .= ' [no_merges]'
  endif
  if a:opts.reflog
    let l:name .= ' [reflog]'
  endif
  if a:opts.reverse
    let l:name .= ' [reverse]'
  endif
  if !a:opts.graph
    let l:name .= ' [no_graph]'
  endif
  if a:opts.patch == v:true && !l:is_patch_implied
    let l:name .= ' [patch]'
  elseif a:opts.patch == v:false && l:is_patch_implied
    let l:name .= ' [no_patch]'
  endif
  if !empty(a:opts.skip)
    let l:name .= ' [skip=' . a:opts.skip . ']'
  endif
  if !empty(a:opts.order)
    let l:name .= ' [order=' . a:opts.order . ']'
  endif
  if !empty(a:opts.max_count)
    let l:name .= ' [max_count=' . a:opts.max_count . ']'
  endif
  if !empty(a:opts.search)
    let l:name .= ' [search=' . flog#str#Ellipsize(a:opts.search, 15) . ']'
  endif
  if !empty(a:opts.patch_search)
    let l:name .= ' [patch_search=' . flog#str#Ellipsize(a:opts.patch_search, 15) . ']'
  endif
  if !empty(a:opts.author)
    let l:name .= ' [author=' . a:opts.author . ']'
  endif
  if !empty(a:opts.limit)
    let [range, path] = flog#args#SplitGitLimitArg(a:opts.limit)
    let l:name .= ' [limit=' . flog#str#Ellipsize(range . fnamemodify(path, ':t'), 15) . ']'
  endif
  if len(a:opts.rev) == 1
    let l:name .= ' [rev=' . flog#str#Ellipsize(a:opts.rev[0], 15) . ']'
  endif
  if len(a:opts.rev) > 1
    let l:name .= ' [rev=...]'
  endif
  if a:opts.related && !a:opts.limit
    let l:name .= ' [related]'
  endif
  if len(a:opts.path) == 1
    let l:name .= ' [path=' . flog#str#Ellipsize(fnamemodify(a:opts.path[0], ':t'), 15) . ']'
  elseif len(a:opts.path) > 1
    let l:name .= ' [path=...]'
  endif

  return fnameescape(l:name)
endfunction

function! flog#floggraph#buf#Open(state) abort
  let l:bufname = flog#floggraph#buf#GetInitialName(a:state.instance_number)
  execute 'silent! ' . a:state.opts.open_cmd . l:bufname

  call flog#state#SetBufState(a:state)

  let l:bufnr = bufnr()
  call flog#state#SetGraphBufnr(a:state, l:bufnr)

  call flog#backend#SetupGitBuffer(flog#state#GetWorkdir(a:state))
  exec 'lcd ' . flog#git#GetWorkdir()

  setlocal filetype=floggraph

  return l:bufnr
endfunction

function! flog#floggraph#buf#Update() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()
  let l:opts = flog#state#GetResolvedOpts(l:state)

  " Record previous window
  let l:graph_win = flog#win#Save()

  " Update buffer status
  if g:flog_enable_status
    call flog#floggraph#buf#UpdateStatus()
  endif

  " Build command
  let l:cmd = flog#floggraph#git#BuildLogCmd()
  call flog#state#SetPrevLogCmd(l:state, l:cmd)

  " Build graph
  if has('nvim')
    let l:graph = flog#graph#nvim#Get(l:cmd)
  else
    let l:graph = flog#graph#vim#Get(l:cmd)
  endif

  " Record previous commit
  let l:last_commit = flog#floggraph#commit#GetAtLine('.')

  " Update graph
  call flog#state#SetGraph(l:state, l:graph)
  call flog#floggraph#buf#SetContent(l:graph.output)

  " Restore commit position
  call flog#floggraph#commit#RestorePosition(l:graph_win, l:last_commit)

  " Set buffer name
  silent! exec 'keepalt file ' . flog#floggraph#buf#GetName(l:state.instance_number, l:opts)

  if has('nvim')
    " Initialize Neovim auto-updates
    if flog#floggraph#opts#ShouldAutoUpdate()
      call v:lua.require('flog/watch').nvim_register_floggraph_buf()
    end

    " Initialize Neovim autocommands
    call v:lua.require('flog/autocmd').nvim_create_graph_autocmds(
          \ l:state.graph_bufnr,
          \ l:state.instance_number,
          \ l:state.opts.graph)
  endif

  " Execute user autocommands
  if exists('#User#FlogUpdate')
    doautocmd User FlogUpdate
  endif

  return l:state.graph_bufnr
endfunction

function! flog#floggraph#buf#Redraw() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  " Record previous window
  let l:graph_win = flog#win#Save()

  " Rebuild graph
  if has('nvim')
    let l:graph = flog#graph#nvim#Update(l:state)
  else
    let l:graph = flog#graph#vim#Update(l:state)
  endif

  " Record previous commit
  let l:last_commit = flog#floggraph#commit#GetAtLine('.')

  " Update graph
  call flog#state#SetGraph(l:state, l:graph)
  call flog#floggraph#buf#SetContent(l:graph.output)

  " Restore commit position
  call flog#floggraph#commit#RestorePosition(l:graph_win, l:last_commit)

  " Initialize Neovim autocommands
  if has('nvim')
    call v:lua.require('flog/autocmd').nvim_create_graph_autocmds(
          \ l:state.graph_bufnr,
          \ l:state.instance_number,
          \ l:state.opts.graph)
  endif

  return l:state.graph_bufnr
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

function! flog#floggraph#buf#ExecuteUpdateHookWhenSafe(bufnr) abort
  if !exists('##SafeState')
    return flog#floggraph#buf#FinishUpdateHook(a:bufnr)
  endif

  if bufnr() != a:bufnr
    return -1
  endif

  let l:buf = string(a:bufnr)
  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' . l:buf . '>'
    exec 'autocmd SafeState <buffer=' . l:buf . '> call flog#floggraph#buf#FinishUpdateHook(' . l:buf . ')'
  augroup END

  return a:bufnr
endfunction

function! flog#floggraph#buf#InitUpdateHook(bufnr) abort
  let l:buf = string(a:bufnr)

  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' . l:buf . '>'
    exec 'autocmd BufEnter <buffer=' . l:buf . '> call flog#floggraph#buf#ExecuteUpdateHookWhenSafe(' . l:buf . ')'
  augroup END

  return a:bufnr
endfunction

function! flog#floggraph#buf#SetContent(content) abort
  call flog#floggraph#buf#AssertFlogBuf()

  setlocal modifiable noreadonly
  silent! 1,$ delete _
  call setline(1, a:content)
  setlocal nomodifiable readonly

  return a:content
endfunction

function! flog#floggraph#buf#Close() abort
  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:graph_win = flog#win#Save()
  call flog#floggraph#side_win#CloseTmp()

  call flog#win#Restore(l:graph_win)
  if flog#win#Is(l:graph_win)
    let l:tab_info = flog#tab#GetInfo()
    silent! bdelete!
    if flog#tab#DidCloseRight(l:tab_info)
      tabprev
    endif
  endif

  return l:graph_win.win_id
endfunction
