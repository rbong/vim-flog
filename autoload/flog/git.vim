vim9script

#
# This file contains functions for working with git.
#

export def HasCommitGraph(): bool
  var path = flog#fugitive#GetGitDir()
  path ..= '/objects/info/commit-graph'
  return filereadable(path)
enddef

export def WriteCommitGraph(): string
  var cmd = 'Git commit-graph write '
  cmd ..= g:flog_write_commit_graph_args

  exec cmd

  return cmd
enddef

export def GetAuthors(): list<string>
  var cmd = flog#fugitive#GetGitCommand()
  cmd ..= ' shortlog -s -n '
  cmd ..= g:flog_get_author_args

  var result = flog#shell#Run(cmd)

  # Filter author commit numbers before returning
  return map(copy(result), (_, val) => substitute(val, '^\s*\d*\s*', '', ''))
enddef

export def GetRefs(): list<string>
  var cmd = flog#fugitive#GetGitCommand()
  cmd ..= ' rev-parse --symbolic --branches --tags --remotes'

  return flog#shell#Run(cmd) + ['HEAD', 'FETCH_HEAD', 'ORIG_HEAD']
enddef
