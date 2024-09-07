"
" This file contains functions for creating and updating the internal state
" object.
"

let g:flog_instance_counter = 0

function! flog#state#Create() abort
  let l:state = {
        \ 'instance_number': g:flog_instance_counter,
        \ 'opts': {},
        \ 'prev_log_cmd': '',
        \ 'graph_bufnr': -1,
        \ 'workdir': '',
        \ 'commits': [],
        \ 'commits_by_hash': {},
        \ 'line_commits': [],
        \ 'commit_marks': {},
        \ 'tmp_side_wins': [],
        \ 'commit_jumplist': [],
        \ 'commit_jumplist_index': -1,
        \ 'collapsed_commits': {},
        \ }

  let g:flog_instance_counter += 1

  return l:state
endfunction

function! flog#state#GetInternalDefaultOpts() abort
  let l:open_cmd = flog#win#IsTabEmpty() ? 'edit' : 'tabedit'

  let l:format = '%ad [%h] {%an}%d %s'
  if g:flog_enable_dynamic_commit_hl
    let l:format = '%ad %h %an%d %s'
  endif

  let l:defaults = {
        \ 'raw_args': '',
        \ 'format': l:format,
        \ 'date': 'iso',
        \ 'all': v:false,
        \ 'auto_update': v:false,
        \ 'bisect': v:false,
        \ 'default_collapsed': v:false,
        \ 'first_parent': v:false,
        \ 'merges': v:true,
        \ 'reflog': v:false,
        \ 'related': v:false,
        \ 'reverse': v:false,
        \ 'graph': v:true,
        \ 'patch': -1,
        \ 'skip': '',
        \ 'order': '',
        \ 'max_count': '5000',
        \ 'open_cmd': l:open_cmd,
        \ 'search': '',
        \ 'patch_search': '',
        \ 'author': '',
        \ 'limit': '',
        \ 'rev': [],
        \ 'path': [],
        \ }

  " Show deprecation warning for old setting
  call flog#deprecate#Setting(
        \ 'g:flog_permanent_default_arguments',
        \ 'g:flog_permanent_default_opts'
        \ )

  " Read the user immutable defaults
  if exists('g:flog_permanent_default_opts')
    for [l:key, l:value] in items(g:flog_permanent_default_opts)
      if has_key(l:defaults, l:key)
        let l:defaults[key] = l:value
      else
        call flog#print#err('flog: warning: unrecognized permanent default option "%s"', l:key)
      endif
    endfor
  endif

  if type(l:defaults.max_count) == v:t_number
    let l:defaults.max_count = string(l:defaults.max_count)
  endif

  if type(l:defaults.skip) == v:t_number
    let l:defaults.skip = string(l:defaults.skip)
  endif

  return l:defaults
endfunction

function! flog#state#GetDefaultOpts() abort
  let l:defaults = flog#state#GetInternalDefaultOpts()

  " Show deprecation warning for old setting
  call flog#deprecate#Setting(
        \ 'g:flog_default_arguments',
        \ 'g:flog_default_opts'
        \ )

  " Read the user defaults
  if exists('g:flog_default_opts')
    for [l:key, l:value] in items(g:flog_default_opts)
      if has_key(l:defaults, l:key)
        let l:defaults[key] = l:value
      else
        call flog#print#err('flog: warning: unrecognized default option "%s"', l:key)
      endif
    endfor
  endif

  if type(l:defaults.max_count) == v:t_number
    let l:defaults.max_count = string(l:defaults.max_count)
  endif

  if type(l:defaults.skip) == v:t_number
    let l:defaults.skip = string(l:defaults.skip)
  endif

  return l:defaults
endfunction

function! flog#state#SetOpts(state, opts) abort
  let a:state.opts = a:opts
  return a:opts
endfunction

function! flog#state#GetOpts(state) abort
  return a:state.opts
endfunction

function! flog#state#GetResolvedOpts(state) abort
  let l:opts = copy(a:state.opts)

  let l:opts.bisect = l:opts.bisect && !l:opts.limit
  let l:opts.reflog = l:opts.reflog && !l:opts.limit

  return l:opts
endfunction

function! flog#state#SetPrevLogCmd(state, prev_log_cmd) abort
  let a:state.prev_log_cmd = a:prev_log_cmd
  return a:prev_log_cmd
endfunction

function! flog#state#SetGraphBufnr(state, bufnr) abort
  let a:state.graph_bufnr = a:bufnr
  return a:bufnr
endfunction

function! flog#state#SetWorkdir(state, workdir) abort
  let a:state.workdir = a:workdir
  return a:workdir
endfunction

function! flog#state#GetWorkdir(state) abort
  return a:state.workdir
endfunction

function! flog#state#GetCommitRefs(commit) abort
  let l:refs = []

  let l:remotes = flog#git#GetRemotes()

  for l:ref in split(a:commit.refs, ', ')
    let l:match = matchlist(l:ref, '\v^(([^ ]+) -\> )?(tag: )?((refs/.{-}/)?(.*))')

    let l:path = l:match[6]
    let [l:remote, l:tail] = flog#git#SplitRemote(l:path, l:remotes)

    " orig: The name of the original path, ex. "HEAD"
    " tag: Whether the ref is a tag
    " prefix: ex. "refs/remotes", "refs/bisect", etc.
    " remote: Remote name only
    " full: Full path including refs/.*/
    " path: Path with remote
    " tail: End of path only (no remote)
    call add(l:refs, {
          \ 'orig': l:match[2],
          \ 'tag': !empty(l:match[3]),
          \ 'prefix': l:match[5][ : -2],
          \ 'remote': l:remote,
          \ 'full': l:match[4],
          \ 'path': l:path,
          \ 'tail': l:tail,
          \ })
  endfor

  return l:refs
endfunction

function! flog#state#SetGraph(state, graph) abort
  " Selectively set graph properties
  let a:state.commits = a:graph.commits
  let a:state.commits_by_hash = a:graph.commits_by_hash
  let a:state.line_commits = a:graph.line_commits
  return a:graph
endfunction

function! flog#state#IsReservedCommitMark(key) abort
  return a:key =~# '[<>@~^!]'
endfunction

function! flog#state#IsDynamicCommitMark(key) abort
  return a:key =~# '[<>@~^]'
endfunction

function! flog#state#IsCancelCommitMark(key) abort
  " 27 is the key code for <Esc>
  return char2nr(a:key) == 27
endfunction

function! flog#state#ResetCommitMarks(state) abort
  let l:new_commit_marks = {}
  let a:state.commit_marks = l:new_commit_marks
  return l:new_commit_marks
endfunction

function! flog#state#HasCommitMark(state, key) abort
  if flog#state#IsDynamicCommitMark(a:key)
    return v:true
  endif
  if flog#state#IsCancelCommitMark(a:key)
    throw g:flog_invalid_commit_mark
  endif
  return has_key(a:state.commit_marks, a:key)
endfunction

function! flog#state#SetInternalCommitMark(state, key, commit) abort
  let a:state.commit_marks[a:key] = a:commit
  return a:commit
endfunction

function! flog#state#SetCommitMark(state, key, commit) abort
  if flog#state#IsReservedCommitMark(a:key)
    throw g:flog_invalid_commit_mark
  endif
  return flog#state#SetInternalCommitMark(a:state, a:key, a:commit)
endfunction

function! flog#state#GetCommitMark(state, key) abort
  return get(a:state.commit_marks, a:key, {})
endfunction

function! flog#state#RemoveCommitMark(state, key) abort
  if !has_key(a:state.commit_marks, a:key)
    return {}
  endif
  return remove(a:state.commit_marks, a:key)
endfunction

function! flog#state#SetTmpSideWins(state, tmp_side_wins) abort
  let a:state.tmp_side_wins = a:tmp_side_wins
  return a:tmp_side_wins
endfunction

function! flog#state#ResetTmpSideWins(state) abort
  return flog#state#SetTmpSideWins(a:state, [])
endfunction

function! flog#state#SetBufState(state) abort
  let b:flog_state = a:state
endfunction

function! flog#state#HasBufState() abort
  return exists('b:flog_state')
endfunction

function! flog#state#GetBufState() abort
  if !flog#state#HasBufState()
    throw g:flog_missing_state
  endif
  return b:flog_state
endfunction
