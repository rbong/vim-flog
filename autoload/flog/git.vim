vim9script

#
# This file contains functions for working with git.
#

def flog#git#has_commit_graph(): bool
  var path = flog#fugitive#get_git_dir()
  path ..= '/objects/info/commit-graph'
  return filereadable(path)
enddef

def flog#git#write_commit_graph(): string
  var cmd = 'Git commit-graph write '
  cmd ..= g:flog_write_commit_graph_args

  exec cmd

  return cmd
enddef

def flog#git#get_authors(): list<string>
  var cmd = flog#fugitive#get_git_command()
  cmd ..= ' shortlog -s -n '
  cmd ..= g:flog_get_author_args

  var result = flog#shell#run(cmd)

  # Filter author commit numbers before returning
  return map(copy(result), (_, val) => substitute(val, '^\s*\d*\s*', '', ''))
enddef

def flog#git#get_refs(): list<string>
  var cmd = flog#fugitive#get_git_command()
  cmd ..= ' rev-parse --symbolic --branches --tags --remotes'

  return flog#shell#run(cmd) + ['HEAD', 'FETCH_HEAD', 'ORIG_HEAD']
enddef
