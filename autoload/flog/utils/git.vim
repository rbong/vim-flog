vim9script

#
# This file contains functions for working with git.
#

def flog#utils#git#get_authors(): list<string>
  var cmd = flog#fugitive#get_git_command()
  cmd ..= ' shortlog -s -n '
  cmd ..= g:flog_get_author_args

  var result = flog#utils#shell#run(cmd)

  # Filter author commit numbers before returning
  return map(copy(result), (_, val) => substitute(val, '^\s*\d*\s*', '', ''))
enddef

def flog#utils#git#get_refs(): list<string>
  var cmd = flog#fugitive#get_git_command()
  cmd ..= ' rev-parse --symbolic --branches --tags --remotes'

  return flog#utils#shell#run(cmd) + ['HEAD', 'FETCH_HEAD', 'ORIG_HEAD']
enddef
