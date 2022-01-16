vim9script

#
# This file contains functions for creating and updating the ":Flog" buffer.
#

def flog#cmd#flog#buf#assert_flog_buf(): bool
  if &filetype != 'floggraph'
    throw g:flog_not_a_flog_buffer
  endif
  return true
enddef

def flog#cmd#flog#buf#get_name(instance_number: number, opts: dict<any>): string
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

def flog#cmd#flog#buf#open(state: dict<any>): number
  const bufname = ' flog-' .. string(state.instance_number) .. ' [uninitialized]'
  execute 'silent! ' .. state.opts.open_cmd .. bufname

  flog#state#set_buf_state(state)

  var bufnr = bufnr()
  flog#state#set_graph_bufnr(state, bufnr)

  flog#fugitive#trigger_detection(flog#state#get_fugitive_workdir(state))

  setlocal buftype=nofile nobuflisted nomodifiable nowrap
  setlocal filetype=floggraph

  return bufnr
enddef

def flog#cmd#flog#buf#update(): number
  flog#cmd#flog#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()
  const opts = flog#state#get_resolved_opts(state)

  const cmd = flog#cmd#flog#git#build_log_cmd()
  const parsed = flog#cmd#flog#git#parse_log_output(flog#shell#run(cmd))
  flog#state#set_commits(state, parsed.commits)

  var graph = {}

  if opts.graph
    graph = flog#graph#generate(parsed.commits, parsed.all_commit_content)
  else
    graph = flog#graph#generate_commits_only(parsed.commits, parsed.all_commit_content)
  endif

  # Record previous commit
  const last_commit = flog#cmd#flog#nav#get_commit_at_line('.')

  flog#state#set_graph(state, graph)
  flog#cmd#flog#buf#set_content(graph.output)

  # Restore commit
  if !empty(last_commit)
    flog#cmd#flog#nav#jump_to_commit(last_commit.hash)
  endif

  exec 'file ' .. flog#cmd#flog#buf#get_name(state.instance_number, opts)

  return state.graph_bufnr
enddef

def flog#cmd#flog#buf#set_content(content: list<string>): list<string>
  flog#cmd#flog#buf#assert_flog_buf()

  set modifiable
  :1,$ delete
  setline(1, content)
  set nomodifiable

  return content
enddef
