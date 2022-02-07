vim9script

#
# This file contains functions for working with git for "floggraph" buffers.
#

export def BuildLogFormat(): string
  const state = flog#state#GetBufState()
  const opts = flog#state#GetResolvedOpts(state)

  var format = 'format:'
  # Add token so we can find commits
  format ..= g:flog_commit_start_token
  # Add commit data
  format ..= '%n%h%n%p%n%D%n'
  # Add user format
  format ..= opts.format

  return flog#shell#Escape(format)
enddef

export def BuildLogArgs(): string
  const state = flog#state#GetBufState()
  const opts = flog#state#GetResolvedOpts(state)

  if opts.reverse && opts.graph
    throw g:flog_reverse_requires_no_graph
  endif

  var args = ''

  if opts.graph
    args ..= ' --parents --topo-order'
  endif
  args ..= ' --no-color'
  args ..= ' --pretty=' .. BuildLogFormat()
  args ..= ' --date=' .. flog#shell#Escape(opts.date)
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
    args ..= ' --skip=' .. flog#shell#Escape(opts.skip)
  endif
  if !empty(opts.sort)
    const sort_type = flog#global_opts#GetSortType(opts.sort)
    args ..= ' ' .. sort_type.args
  endif
  if !empty(opts.max_count)
    args ..= ' --max-count=' .. flog#shell#Escape(opts.max_count)
  endif
  if !empty(opts.search)
    args ..= ' --grep=' .. flog#shell#Escape(opts.search)
  endif
  if !empty(opts.patch_search)
    args ..= ' -G' .. flog#shell#Escape(opts.patch_search)
  endif
  if !empty(opts.author)
    args ..= ' --author=' .. flog#shell#Escape(opts.author)
  endif
  if !empty(opts.limit)
    args ..= ' -L' .. flog#shell#Escape(opts.limit)
  endif
  if !empty(opts.raw_args)
    args ..= ' ' .. opts.raw_args
  endif
  if len(opts.rev) >= 1
    var rev = ''
    if !empty(opts.limit)
      rev = flog#shell#Escape(opts.rev[0])
    else
      rev = join(flog#shell#EscapeList(opts.rev), ' ')
    endif
    args ..= ' ' .. rev
  endif

  return args
enddef

export def BuildLogPaths(): string
  const state = flog#state#GetBufState()
  const opts = flog#state#GetResolvedOpts(state)

  if !empty(opts.limit)
    return ''
  endif

  if empty(opts.path)
    return ''
  endif

  return join(flog#shell#EscapeList(opts.path), ' ')
enddef

export def BuildLogCmd(): string
  var cmd = flog#fugitive#GetGitCommand()

  cmd ..= ' log'
  cmd ..= BuildLogArgs()
  cmd ..= ' -- '
  cmd ..= BuildLogPaths()

  return cmd
enddef
