vim9script

#
# This file contains functions for creating and updating the ":Flog" buffer.
#

def flog#cmd#flog#buf#get_name(state: dict<any>): string
  const opts = flog#state#get_resolved_opts(state)

  var name = 'flog-' .. string(state.instance_number)

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
    name ..= ' [search=' .. flog#utils#str#ellipsize(opts.search, 15) .. ']'
  endif
  if !empty(opts.patch_search)
    name ..= ' [patch_search=' .. flog#utils#str#ellipsize(opts.patch_search, 15) .. ']'
  endif
  if !empty(opts.author)
    name ..= ' [author=' .. opts.author .. ']'
  endif
  if !empty(opts.limit)
    const [range, path] = flog#utils#args#split_git_limit_arg(opts.limit)
    name ..= ' [limit=' .. flog#utils#str#ellipsize(range .. fnamemodify(path, ':t'), 15) .. ']'
  endif
  if len(opts.rev) == 1
    name ..= ' [rev=' .. flog#utils#str#ellipsize(opts.rev[0], 15) .. ']'
  endif
  if len(opts.rev) > 1
    name ..= ' [rev=...]'
  endif
  if len(opts.path) == 1
    name ..= ' [path=' .. flog#utils#str#ellipsize(fnamemodify(opts.path[0], ':t'), 15) .. ']'
  elseif len(opts.path) > 1
    name ..= ' [path=...]'
  endif

  return name
enddef

def flog#cmd#flog#buf#open(state: dict<any>): number
  execute state.opts.open_cmd .. ' ' .. flog#cmd#flog#buf#get_name(state)

  flog#state#set_buf_state(state)

  var bufnr = bufnr()
  flog#state#set_graph_bufnr(state, bufnr)

  flog#fugitive#trigger_detection(flog#state#get_fugitive_workdir(state))

  setlocal buftype=nofile nobuflisted nomodifiable nowrap
  set ft=floggraph

  return bufnr
enddef

def flog#cmd#flog#buf#set_content(content: list<string>): list<string>
  set modifiable
  :1,$ delete
  setline(1, content)
  set nomodifiable

  return content
enddef
