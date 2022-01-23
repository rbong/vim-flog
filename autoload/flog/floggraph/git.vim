vim9script

#
# This file contains functions for working with git for "floggraph" buffers.
#

def flog#floggraph#git#build_log_format(): string
  const state = flog#state#get_buf_state()
  const opts = flog#state#get_resolved_opts(state)

  var format = 'format:'
  # Add token so we can find commits
  format ..= g:flog_commit_start_token
  # Add commit data
  format ..= '%n%h%n%p%n%D%n'
  # Add user format
  format ..= opts.format

  return flog#shell#escape(format)
enddef

def flog#floggraph#git#build_log_args(): string
  const state = flog#state#get_buf_state()
  const opts = flog#state#get_resolved_opts(state)

  if opts.reverse && opts.graph
    throw g:flog_reverse_requires_no_graph
  endif

  var args = ''

  if opts.graph
    args ..= ' --parents --topo-order'
  endif
  args ..= ' --no-color'
  args ..= ' --pretty=' .. flog#floggraph#git#build_log_format()
  args ..= ' --date=' .. flog#shell#escape(opts.date)
  if opts.all && empty(opts.limit)
    args ..= ' --all'
  endif
  if opts.bisect
    args ..= ' --bisect'
  endif
  if !opts.merges
    args ..= ' --no-merges'
  endif
  if opts.reflog
    args ..= ' --reflog'
  endif
  if opts.reverse
    args ..= ' --reverse'
  endif
  if !opts.patch
    args ..= ' --no-patch'
  endif
  if !empty(opts.skip)
    args ..= ' --skip=' .. flog#shell#escape(opts.skip)
  endif
  if !empty(opts.sort)
    const sort_type = flog#global_opts#get_sort_type(opts.sort)
    args ..= ' ' .. sort_type.args
  endif
  if !empty(opts.max_count)
    args ..= ' --max-count=' .. flog#shell#escape(opts.max_count)
  endif
  if !empty(opts.search)
    args ..= ' --grep=' .. flog#shell#escape(opts.search)
  endif
  if !empty(opts.patch_search)
    args ..= ' -G' .. flog#shell#escape(opts.patch_search)
  endif
  if !empty(opts.author)
    args ..= ' --author=' .. flog#shell#escape(opts.author)
  endif
  if !empty(opts.limit)
    args ..= ' -L' .. flog#shell#escape(opts.limit)
  endif
  if !empty(opts.raw_args)
    args ..= ' ' .. opts.raw_args
  endif
  if len(opts.rev) >= 1
    var rev = ''
    if !empty(opts.limit)
      rev = flog#shell#escape(opts.rev[0])
    else
      rev = join(flog#shell#escape_list(opts.rev), ' ')
    endif
    args ..= ' ' .. rev
  endif

  return args
enddef

def flog#floggraph#git#build_log_paths(): string
  const state = flog#state#get_buf_state()
  const opts = flog#state#get_resolved_opts(state)

  if !empty(opts.limit)
    return ''
  endif

  if empty(opts.path)
    return ''
  endif

  return join(flog#shell#escape_list(opts.path), ' ')
enddef

def flog#floggraph#git#build_log_cmd(): string
  var cmd = flog#fugitive#get_git_command()

  cmd ..= ' log'
  cmd ..= flog#floggraph#git#build_log_args()
  cmd ..= ' -- '
  cmd ..= flog#floggraph#git#build_log_paths()

  return cmd
enddef

def flog#floggraph#git#parse_log_output(output: list<string>): dict<any>
  var commits = []
  var all_commit_content = []

  var commit = flog#state#create_commit()
  var commit_content = []

  var reached_first_commit = false
  var parsed_hash = false
  var parsed_parents = false
  var parsed_refs = false

  for line in output
    if line == g:flog_commit_start_token
      if !reached_first_commit
        reached_first_commit = true
        continue
      endif

      add(commits, commit)
      add(all_commit_content, commit_content)

      commit = flog#state#create_commit()
      commit_content = []

      parsed_hash = false
      parsed_parents = false
      parsed_refs = false
    elseif !parsed_hash
      flog#state#set_commit_hash(commit, line)
      parsed_hash = true
    elseif !parsed_parents
      flog#state#set_commit_parents(commit, line)
      parsed_parents = true
    elseif !parsed_refs
      flog#state#set_commit_refs(commit, line)
      parsed_refs = true
    else
      add(commit_content, line)
    endif
  endfor

  # Add last commit
  if parsed_refs
    add(commits, commit)
    add(all_commit_content, commit_content)
  endif

  if len(output) > 1 && empty(commits)
    throw g:flog_no_commits_found
  endif

  return {
    commits: commits,
    all_commit_content: all_commit_content
    }
enddef
