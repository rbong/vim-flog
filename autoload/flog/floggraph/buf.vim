vim9script

#
# This file contains functions for creating and updating "floggraph" buffers.
#

def flog#floggraph#buf#is_flog_buf(): bool
  return &filetype == 'floggraph'
enddef

def flog#floggraph#buf#assert_flog_buf(): bool
  if !flog#floggraph#buf#is_flog_buf()
    throw g:flog_not_a_flog_buffer
  endif
  return true
enddef

def flog#floggraph#buf#get_name(instance_number: number, opts: dict<any>): string
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
  if !empty(opts.sort) && opts.sort != 'topo'
    name ..= ' [sort=' .. opts.sort .. ']'
  endif
  if !empty(opts.max_count)
    name ..= ' [max_count=' .. opts.max_count .. ']'
  endif
  if !empty(opts.search)
    name ..= ' [search=' .. flog#str#ellipsize(opts.search, 15) .. ']'
  endif
  if !empty(opts.patch_search)
    name ..= ' [patch_search=' .. flog#str#ellipsize(opts.patch_search, 15) .. ']'
  endif
  if !empty(opts.author)
    name ..= ' [author=' .. opts.author .. ']'
  endif
  if !empty(opts.limit)
    const [range, path] = flog#args#split_git_limit_arg(opts.limit)
    name ..= ' [limit=' .. flog#str#ellipsize(range .. fnamemodify(path, ':t'), 15) .. ']'
  endif
  if len(opts.rev) == 1
    name ..= ' [rev=' .. flog#str#ellipsize(opts.rev[0], 15) .. ']'
  endif
  if len(opts.rev) > 1
    name ..= ' [rev=...]'
  endif
  if len(opts.path) == 1
    name ..= ' [path=' .. flog#str#ellipsize(fnamemodify(opts.path[0], ':t'), 15) .. ']'
  elseif len(opts.path) > 1
    name ..= ' [path=...]'
  endif

  return name
enddef

def flog#floggraph#buf#open(state: dict<any>): number
  const bufname = ' flog-' .. string(state.instance_number) .. ' [uninitialized]'
  execute 'silent! ' .. state.opts.open_cmd .. bufname

  flog#state#set_buf_state(state)

  var bufnr = bufnr()
  flog#state#set_graph_bufnr(state, bufnr)

  flog#fugitive#trigger_detection(flog#state#get_fugitive_workdir(state))
  exec 'lcd ' .. flog#fugitive#get_workdir()

  setlocal filetype=floggraph

  return bufnr
enddef

def flog#floggraph#buf#update(): number
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()
  const opts = flog#state#get_resolved_opts(state)

  const cmd = flog#floggraph#git#build_log_cmd()
  flog#state#set_prev_log_cmd(state, cmd)
  const parsed = flog#floggraph#git#parse_log_output(flog#shell#run(cmd))
  flog#state#set_commits(state, parsed.commits)

  var graph = {}

  if opts.graph
    graph = flog#graph#generate(parsed.commits, parsed.all_commit_content)
  else
    graph = flog#graph#generate_commits_only(parsed.commits, parsed.all_commit_content)
  endif

  # Record previous commit
  const last_commit = flog#floggraph#commit#get_at_line('.')

  flog#state#set_graph(state, graph)
  flog#floggraph#buf#set_content(graph.output)

  # Restore commit
  if !empty(last_commit)
    flog#floggraph#nav#jump_to_commit(last_commit.hash)
  endif

  silent! exec 'file ' .. flog#floggraph#buf#get_name(state.instance_number, opts)

  return state.graph_bufnr
enddef

def flog#floggraph#buf#finish_update_hook(bufnr: number): number
  if bufnr() != bufnr
    return -1
  endif

  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' .. string(bufnr) .. '>'
  augroup END

  flog#floggraph#buf#update()

  return bufnr
enddef

def flog#floggraph#buf#init_update_hook(bufnr: number): number
  const buf = string(bufnr)

  augroup FlogGraphBufUpdate
    exec 'autocmd! * <buffer=' .. buf .. '>'
    if exists('##SafeState')
      exec 'autocmd SafeState <buffer=' .. buf .. '> call flog#floggraph#buf#finish_update_hook(' .. buf .. ')'
    else
      exec 'autocmd WinEnter <buffer=' .. buf .. '> call flog#floggraph#buf#finish_update_hook(' .. buf .. ')'
    endif
  augroup END

  return bufnr
enddef

def flog#floggraph#buf#set_content(content: list<string>): list<string>
  flog#floggraph#buf#assert_flog_buf()

  set modifiable noreadonly
  :1,$ delete
  setline(1, content)
  set nomodifiable readonly

  return content
enddef

def flog#floggraph#buf#close(): number
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  const graph_win_id = win_getid()
  flog#floggraph#side_win#close_tmp()

  win_gotoid(graph_win_id)
  if win_getid() == graph_win_id
    silent! bdelete!
  endif

  return graph_win_id
enddef
