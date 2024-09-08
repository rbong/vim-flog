"
" This file contains functions for working with git.
"

function! flog#git#GetWorkdir() abort
  let l:git_dir = flog#backend#GetGitDir()
  if empty(l:git_dir)
    return ''
  endif
  return fnamemodify(l:git_dir .. '/', ':p:h:h')
endfunction

function! flog#git#GetCommand(cmd = '') abort
  let l:cmd = 'git -C ' . flog#shell#Escape(flog#git#GetWorkdir())
  if !empty(a:cmd)
    let l:cmd .= ' ' .. a:cmd
  endif
  return l:cmd
endfunction

function! flog#git#HasCommitGraph() abort
  let l:path = flog#backend#GetGitDir()
  let l:path .= '/objects/info/commit-graph'
  return filereadable(l:path)
endfunction

function! flog#git#WriteCommitGraph() abort
  let l:cmd =  flog#backend#GetUserCommand() .. ' commit-graph write '
  let l:cmd .= g:flog_write_commit_graph_args

  exec l:cmd

  return l:cmd
endfunction

function! flog#git#GetAuthors() abort
  let l:cmd = flog#git#GetCommand('shortlog -s -n ')
  let l:cmd .= g:flog_get_author_args

  let l:result = flog#shell#Run(l:cmd)

  " Filter author commit numbers before returning
  return map(copy(l:result), 'substitute(v:val, "^\\s*\\d*\\s*", "", "")')
endfunction

function! flog#git#GetRefs() abort
  let l:cmd = flog#git#GetCommand()
  let l:cmd .= ' rev-parse --symbolic --branches --tags --remotes'

  return flog#shell#Run(l:cmd) + ['HEAD', 'FETCH_HEAD', 'ORIG_HEAD']
endfunction

function! flog#git#GetRemotes() abort
  let l:cmd = flog#git#GetCommand('remote -v')

  let l:remotes = flog#shell#Run(l:cmd)

  return uniq(sort(map(l:remotes, 'substitute(v:val, "\t.*$", "", "")')))
endfunction

function! flog#git#SplitRemote(ref, remotes) abort
  for l:remote in a:remotes
    let l:len = len(l:remote)
    if a:ref[ : l:len - 1] ==# l:remote
      return [l:remote, a:ref[l:len + 1 : ]]
    endif
  endfor

  return ['', a:ref]
endfunction

function! flog#git#GetHeadRef() abort
  let l:cmd = flog#git#GetCommand('symbolic-ref --short HEAD')
  return flog#shell#Run(l:cmd)[0]
endfunction

function! flog#git#GetRelatedRefs(revs = []) abort
  let l:related_refs = []

  " Remove duplicates and filter
  let l:revs = uniq(sort(filter(a:revs, '!empty(v:val)')))

  " Use HEAD if empty
  if empty(l:revs)
    let l:revs = ['HEAD']
  endif

  " Resolve HEAD
  let l:head_index = index(l:revs, 'HEAD')
  if l:head_index >= 0
    let l:head_ref = flog#git#GetHeadRef()
    if empty(l:head_ref)
      call add(related_refs, 'HEAD')
      call remove(l:revs, l:head_index)
    else
      let l:revs[l:head_index] = l:head_ref
    endif
  endif

  " Early exit if revs are empty
  if empty(l:revs)
    return l:related_refs
  endif

  " Get data from Git
  let l:remotes = flog#git#GetRemotes()
  let l:all_refs = flog#git#GetRefs()

  " Strip remote from revs
  let l:check_revs = {}
  for l:rev in l:revs
    let l:check_revs[flog#git#SplitRemote(l:rev, l:remotes)[1]] = 1
  endfor

  " Find related refs
  for l:ref in l:all_refs
    " Strip remote from ref
    let l:stripped_ref = flog#git#SplitRemote(l:ref, l:remotes)[1]
    " Check if ref matches
    if has_key(l:check_revs, l:stripped_ref)
      call add(l:related_refs, l:ref)
    endif
  endfor

  return l:related_refs
endfunction
