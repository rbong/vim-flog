"
" This file contains functions for working with git.
"

function! flog#git#HasCommitGraph() abort
  let l:path = flog#fugitive#GetGitDir()
  let l:path .= '/objects/info/commit-graph'
  return filereadable(l:path)
endfunction

function! flog#git#WriteCommitGraph() abort
  let l:cmd = 'Git commit-graph write '
  let l:cmd .= g:flog_write_commit_graph_args

  exec l:cmd

  return l:cmd
endfunction

function! flog#git#GetAuthors() abort
  let l:cmd = flog#fugitive#GetGitCommand()
  let l:cmd .= ' shortlog -s -n '
  let l:cmd .= g:flog_get_author_args

  let l:result = flog#shell#Run(l:cmd)

  " Filter author commit numbers before returning
  return map(copy(l:result), 'substitute(v:val, "^\\s*\\d*\\s*", "", "")')
endfunction

function! flog#git#GetRefs() abort
  let l:cmd = flog#fugitive#GetGitCommand()
  let l:cmd .= ' rev-parse --symbolic --branches --tags --remotes'

  return flog#shell#Run(l:cmd) + ['HEAD', 'FETCH_HEAD', 'ORIG_HEAD']
endfunction
