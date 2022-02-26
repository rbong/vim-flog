vim9script

#
# This file contains functions for creating and updating the internal state
# object.
#

import autoload 'flog/deprecate.vim'

g:flog_instance_counter = 0

export def Create(): dict<any>
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

export def GetInternalDefaultOpts(): dict<any>
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
        'order': '',
        'max_count': '5000',
        'open_cmd': 'tabedit',
        'search': '',
        'patch_search': '',
        'author': '',
        'limit': '',
        'rev': [],
        'path': [],
        }

  # Show deprecation warning for old setting
  deprecate.Setting(
    'g:flog_permanent_default_arguments',
    'g:flog_permanent_default_opts'
    )

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

export def GetDefaultOpts(): dict<any>
  var defaults = GetInternalDefaultOpts()

  # Show deprecation warning for old setting
  deprecate.Setting(
    'g:flog_default_arguments',
    'g:flog_default_opts'
    )

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

export def SetOpts(state: dict<any>, opts: dict<any>): dict<any>
  state.opts = opts
  return opts
enddef

export def GetOpts(state: dict<any>): dict<any>
  return state.opts
enddef

export def GetResolvedOpts(state: dict<any>): dict<any>
  var opts = copy(state.opts)

  opts.bisect = opts.bisect && !opts.limit
  opts.reflog = opts.reflog && !opts.limit

  return opts
enddef

export def SetPrevLogCmd(state: dict<any>, prev_log_cmd: string): string
  state.prev_log_cmd = prev_log_cmd
  return prev_log_cmd
enddef

export def SetGraphBufnr(state: dict<any>, bufnr: number): number
  state.graph_bufnr = bufnr
  return bufnr
enddef

export def SetFugitiveRepo(state: dict<any>, fugitive_repo: dict<any>): dict<any>
  state.fugitive_repo = fugitive_repo
  return fugitive_repo
enddef

export def GetFugitiveWorkdir(state: dict<any>): string
  return state.fugitive_repo.tree()
enddef

export def GetCommitRefs(commit: dict<any>): list<dict<any>>
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

export def SetGraph(state: dict<any>, graph: dict<any>): dict<any>
  # Selectively set graph properties
  state.commits = graph.commits
  state.commits_by_hash = graph.commits_by_hash
  state.line_commits = graph.line_commits
  return graph
enddef

export def IsReservedCommitMark(key: string): bool
  return key =~ '[<>@~^!]'
enddef

export def IsDynamicCommitMark(key: string): bool
  return key =~ '[<>@~^]'
enddef

export def IsCancelCommitMark(key: string): bool
  # 27 is the key code for <Esc>
  return char2nr(key) == 27
enddef

export def ResetCommitMarks(state: dict<any>): dict<any>
  var new_commit_marks = {}
  state.commit_marks = new_commit_marks
  return new_commit_marks
enddef

export def HasCommitMark(state: dict<any>, key: string): bool
  if IsDynamicCommitMark(key)
    return true
  endif
  if IsCancelCommitMark(key)
    throw g:flog_invalid_commit_mark
  endif
  return has_key(state.commit_marks, key)
enddef

export def SetInternalCommitMark(state: dict<any>, key: string, commit: dict<any>): dict<any>
  state.commit_marks[key] = commit
  return commit
enddef

export def SetCommitMark(state: dict<any>, key: string, commit: dict<any>): dict<any>
  if IsReservedCommitMark(key)
    throw g:flog_invalid_commit_mark
  endif
  return SetInternalCommitMark(state, key, commit)
enddef

export def GetCommitMark(state: dict<any>, key: string): dict<any>
  return get(state.commit_marks, key, {})
enddef

export def RemoveCommitMark(state: dict<any>, key: string): dict<any>
  if !has_key(state.commit_marks, key)
    return {}
  endif
  return remove(state.commit_marks, key)
enddef

export def SetTmpSideWins(state: dict<any>, tmp_side_wins: list<number>): list<number>
  state.tmp_side_wins = tmp_side_wins
  return tmp_side_wins
enddef

export def ResetTmpSideWins(state: dict<any>): list<number>
  return SetTmpSideWins(state, [])
enddef

export def SetBufState(state: dict<any>)
  b:flog_state = state
enddef

export def HasBufState(): bool
  return exists('b:flog_state')
enddef

export def GetBufState(): dict<any>
  if !HasBufState()
    throw g:flog_missing_state
  endif
  return b:flog_state
enddef
