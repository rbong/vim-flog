vim9script

#
# This file contains functions for creating and updating the internal state
# object.
#

g:flog_instance_counter = 0

def flog#state#create(): dict<any>
  var state = {
    instance_number: g:flog_instance_counter,
    opts: {},
    graph_bufnr: -1,
    fugitive_repo: {},
    commits: [],
    line_commits: [],
    commit_lines: {},
    commit_cols: {},
    }

  g:flog_instance_counter += 1

  return state
enddef

def flog#state#get_internal_default_opts(): dict<any>
  var defaults = {
        'raw_args': '',
        'format': '%ad [%h] {%an}%d %s',
        'date': 'iso8601',
        'all': false,
        'bisect': false,
        'merges': true,
        'reflog': false,
        'reverse': false,
        'graph': true,
        'patch': true,
        'skip': '',
        'sort': '',
        'max_count': '5000',
        'open_cmd': 'tabedit',
        'search': '',
        'patch_search': '',
        'author': '',
        'limit': '',
        'rev': [],
        'path': [],
        }

  # Read the user immutable defaults
  if exists('g:flog_permanent_default_opts')
    for [key, value] in items(g:flog_permanent_default_opts)
      if has_key(defaults, key)
        defaults[key] = value
      else
        echoerr 'Warning: unrecognized permanent default option ' .. key
      endif
    endfor
  endif

  if type(defaults.max_count) == v:t_number
    defaults.max_count = string(defaults.max_count)
  endif

  if type(defaults.skip) == v:t_number
    defaults.skip = string(defaults.skip)
  endif

  return defaults
enddef

def flog#state#get_default_opts(): dict<any>
  var defaults = flog#state#get_internal_default_opts()

  # Read the user defaults
  if exists('g:flog_default_opts')
    for [key, value] in items(g:flog_default_opts)
      if has_key(defaults, key)
        defaults[key] = value
      else
        echoerr 'Warning: unrecognized default option ' .. key
      endif
    endfor
  endif

  if type(defaults.max_count) == v:t_number
    defaults.max_count = string(defaults.max_count)
  endif

  if type(defaults.skip) == v:t_number
    defaults.skip = string(defaults.skip)
  endif

  return defaults
enddef

def flog#state#set_opts(state: dict<any>, opts: dict<any>): dict<any>
  state.opts = opts
  return opts
enddef

def flog#state#get_opts(state: dict<any>): dict<any>
  return state.opts
enddef

def flog#state#get_resolved_opts(state: dict<any>): dict<any>
  var opts = copy(state.opts)

  opts.bisect = opts.bisect && !opts.limit
  opts.reflog = opts.reflog && !opts.limit

  return opts
enddef

def flog#state#set_graph_bufnr(state: dict<any>, bufnr: number): number
  state.graph_bufnr = bufnr
  return bufnr
enddef

def flog#state#set_fugitive_repo(state: dict<any>, fugitive_repo: dict<any>): dict<any>
  state.fugitive_repo = fugitive_repo
  return fugitive_repo
enddef

def flog#state#get_fugitive_workdir(state: dict<any>): string
  return state.fugitive_repo.tree()
enddef

def flog#state#set_commits(state: dict<any>, commits: list<dict<any>>): list<dict<any>>
  state.commits = commits
  return commits
enddef

def flog#state#create_commit(): dict<any>
  return {
    hash: '',
    # Ordered parent hashes
    parents: [],
    refs: ''
    }
enddef

def flog#state#set_commit_hash(commit: dict<any>, hash: string): string
  commit.hash = hash
  return hash
enddef

def flog#state#set_commit_parents(commit: dict<any>, raw_parents: string): list<string>
  const parents = split(raw_parents)
  const nparents = len(parents)

  commit.parents = parents

  return parents
enddef

def flog#state#set_commit_refs(commit: dict<any>, refs: string): string
  commit.refs = refs
  return refs
enddef

def flog#state#get_commit_refs(commit: dict<any>): list<dict<any>>
  var refs = []

  for ref in split(commit.refs, ', ')
    const match = matchlist(ref, '\v^(([^ ]+) -\> )?(tag: )?((refs/(remote|.*)?/)?((.*/)?(.*)))')

    add(refs, {
      # The name of the original path, ex. "HEAD"
      orig: match[2],
      # Whether the ref is a tag
      tag: !empty(match[3]),
      # Prefix is ex. "refs/remotes", "refs/bisect", etc.
      prefix: match[5][ : -2],
      # Remote name only
      remote: match[8][ : -2],
      # Full path including refs/.*/
      full: match[4],
      # Path with remote
      path: match[7],
      # End of path only (after the last slash)
      tail: match[9],
      })
  endfor

  return refs
enddef

def flog#state#set_graph(state: dict<any>, graph: dict<any>): dict<any>
  # Selectively set graph properties
  state.line_commits = graph.line_commits
  state.commit_lines = graph.commit_lines
  state.commit_cols = graph.commit_cols
  return graph
enddef

def flog#state#set_buf_state(state: dict<any>)
  b:flog_state = state
enddef

def flog#state#has_buf_state(): bool
  return exists('b:flog_state')
enddef

def flog#state#get_buf_state(): dict<any>
  if !flog#state#has_buf_state()
    throw g:flog_missing_state
  endif
  return b:flog_state
enddef
