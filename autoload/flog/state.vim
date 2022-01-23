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
    prev_log_cmd: '',
    graph_bufnr: -1,
    fugitive_repo: {},
    commits: [],
    commits_by_hash: {},
    line_commits: [],
    commit_marks: {},
    tmp_side_wins: [],
    }

  g:flog_instance_counter += 1

  return state
enddef

def flog#state#get_internal_default_opts(): dict<any>
  var defaults = {
        'raw_args': '',
        'format': '%ad [%h] {%an}%d %s',
        'date': 'iso',
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

def flog#state#set_prev_log_cmd(state: dict<any>, prev_log_cmd: string): string
  state.prev_log_cmd = prev_log_cmd
  return prev_log_cmd
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
  state.commits = graph.commits
  state.commits_by_hash = graph.commits_by_hash
  state.line_commits = graph.line_commits
  return graph
enddef

def flog#state#is_reserved_commit_mark(key: string): bool
  return key =~ '[<>@~^!]'
enddef

def flog#state#is_dynamic_commit_mark(key: string): bool
  return key =~ '[<>@~^]'
enddef

def flog#state#is_cancel_commit_mark(key: string): bool
  # 27 is the key code for <Esc>
  return char2nr(key) == 27
enddef

def flog#state#reset_commit_marks(state: dict<any>): dict<any>
  var new_commit_marks = {}
  state.commit_marks = new_commit_marks
  return new_commit_marks
enddef

def flog#state#has_commit_mark(state: dict<any>, key: string): bool
  if flog#state#is_dynamic_commit_mark(key)
    return true
  endif
  if flog#state#is_cancel_commit_mark(key)
    throw g:flog_invalid_commit_mark
  endif
  return has_key(state.commit_marks, key)
enddef

def flog#state#set_internal_commit_mark(state: dict<any>, key: string, commit: dict<any>): dict<any>
  state.commit_marks[key] = commit
  return commit
enddef

def flog#state#set_commit_mark(state: dict<any>, key: string, commit: dict<any>): dict<any>
  if flog#state#is_reserved_commit_mark(key)
    throw g:flog_invalid_commit_mark
  endif
  return flog#state#set_internal_commit_mark(state, key, commit)
enddef

def flog#state#get_commit_mark(state: dict<any>, key: string): dict<any>
  return get(state.commit_marks, key, {})
enddef

def flog#state#remove_commit_mark(state: dict<any>, key: string): dict<any>
  if !has_key(state.commit_marks, key)
    return {}
  endif
  return remove(state.commit_marks, key)
enddef

def flog#state#set_tmp_side_wins(state: dict<any>, tmp_side_wins: list<number>): list<number>
  state.tmp_side_wins = tmp_side_wins
  return tmp_side_wins
enddef

def flog#state#reset_tmp_side_wins(state: dict<any>): list<number>
  return flog#state#set_tmp_side_wins(state, [])
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
