"
" This file contains functions for working with git.
"

function! flog#git#GetWorkdirFrom(git_dir) abort
  " Check for empty git dir
  if empty(a:git_dir)
    return ''
  endif

  let l:cmd = ['git', '--git-dir', flog#shell#Escape(a:git_dir)]
  let l:parent = fnamemodify(a:git_dir, ':h')

  " Check for core.worktree setting
  let l:worktree = flog#shell#Systemlist(l:cmd + ['config', '--get', 'core.worktree'])
  if empty(v:shell_error) && !empty(l:worktree)
    let l:worktree = flog#path#ResolveFrom(a:git_dir, l:worktree[0])
    if isdirectory(l:worktree)
      return l:worktree
    endif
  endif

  " Handle directory-based git dir
  if isdirectory(a:git_dir)
    " Check for git dir file
    let l:gitdir_file = a:git_dir .. '/gitdir'
    if filereadable(l:gitdir_file)
      let l:content = readfile(l:gitdir_file)
      if !empty(l:content)
        let l:workdir = fnamemodify(l:content[0], ':h')
        if l:workdir !=# '.'
          return flog#path#ResolveFrom(l:parent, l:workdir)
        endif
      endif
    endif

    " Check for non-standard git dir
    if !filereadable(a:git_dir .. '/commondir') && !filereadable(a:git_dir .. '/HEAD')
      return ''
    endif
  end

  " Check for non-worktree parent directory
  call flog#shell#Systemlist(l:cmd + ['-C', flog#shell#Escape(l:parent), 'rev-parse', '--show-toplevel'])
  if !empty(v:shell_error)
    return a:git_dir
  endif

  " Default work dir
  return l:parent
endfunction

function! flog#git#GetWorkdir(git_dir = '') abort
  let l:git_dir = empty(a:git_dir) ? flog#backend#GetGitDir() : a:git_dir
  let l:git_dir = fnamemodify(l:git_dir .. '/', ':h:p')
  return flog#git#GetWorkdirFrom(l:git_dir)
endfunction

function! flog#git#GetCommand(cmd = []) abort
  let l:cmd = ['git']

  let l:git_dir = flog#backend#GetGitDir()
  let l:workdir = flog#git#GetWorkdir(l:git_dir)
  if !empty(l:workdir)
    let l:cmd += ['-C', flog#shell#Escape(l:workdir)]
  endif
  if !empty(l:git_dir)
    let l:cmd += ['--git-dir', flog#shell#Escape(l:git_dir)]
  endif

  call extend(l:cmd, a:cmd)

  return l:cmd
endfunction

function! flog#git#HasCommitGraph() abort
  let l:path = flog#backend#GetGitDir()
  let l:path .= '/objects/info/commit-graph'
  return filereadable(l:path)
endfunction

function! flog#git#WriteCommitGraph() abort
  let l:cmd = ['commit-graph', 'write']

  if type(g:flog_write_commit_graph_args) == v:t_string
    call flog#deprecate#Setting(
          \ 'let g:flog_write_commit_graph_args = "string"',
          \ 'g:flog_write_commit_graph_args',
          \ '["list"]'
          \ )
  else
    let l:cmd += g:flog_write_commit_graph_args
  endif

  if get(g:, 'flog_backend_write_commit_graph_with_user_cmd', 1)
    let l:cmd = flog#backend#GetUserCommand() .. ' ' .. join(l:cmd, ' ')
    exec l:cmd
  else
    let l:cmd = flog#git#GetCommand(l:cmd)
    call flog#shell#Run(l:cmd)
  endif

  return l:cmd
endfunction

function! flog#git#GetAuthors() abort
  let l:cmd = flog#git#GetCommand(['shortlog', '-s', '-n'])

  if type(g:flog_get_author_args) == v:t_string
    call flog#deprecate#Setting(
          \ 'let g:flog_get_author_args = "string"',
          \ 'g:flog_get_author_args',
          \ '["list"]'
          \ )
  else
    let l:cmd += g:flog_get_author_args
  endif

  let l:result = flog#shell#Run(l:cmd)

  " Filter author commit numbers before returning
  return map(copy(l:result), 'substitute(v:val, "^\\s*\\d*\\s*", "", "")')
endfunction

function! flog#git#GetRefs() abort
  let l:cmd = flog#git#GetCommand(
        \ ['rev-parse', '--symbolic', '--branches', '--tags', '--remotes'])
  let l:refs = filter(flog#shell#Run(l:cmd), '!empty(v:val)')
  return l:refs + ['HEAD', 'FETCH_HEAD', 'ORIG_HEAD']
endfunction

function! flog#git#GetRemotes() abort
  let l:cmd = flog#git#GetCommand(['remote', '-v'])
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
  let l:cmd = flog#git#GetCommand(['symbolic-ref', '--short', 'HEAD'])
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
