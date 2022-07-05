"
" This file contains functions for handling args to the ":Floggit" command.
"

function! flog#cmd#floggit#args#HasParam(arg) abort
  if a:arg =~# '^--exec-path'
    return v:true
  elseif a:arg =~# '^--work-tree'
    return v:true
  elseif a:arg =~# '^--namespace'
    return v:true
  elseif a:arg =~# '^--super-prefix'
    return v:true
  elseif a:arg =~# '^--config-env'
    return v:true
  endif
  return v:false
endfunction

function! flog#cmd#floggit#args#Parse(args) abort
  let l:nargs = len(a:args)

  " Find command and parse potions

  let l:arg_index = 0
  let l:git_args = []
  let l:subcommand = ''
  let l:options = {
        \ 'focus': v:false,
        \ 'update': v:false,
        \ 'tmp': v:false,
        \ }

  while l:arg_index < l:nargs
    let l:arg = a:args[l:arg_index]

    if l:arg !~# '^-'
      let l:subcommand = l:arg
      break
    endif

    if l:arg ==# '--focus' || l:arg ==# '-f'
      let l:options.focus = v:true
    elseif l:arg ==# '--update' || l:arg ==# '-u'
      let l:options.update = v:true
    elseif l:arg ==# '--tmp' || l:arg ==# '-t'
      let l:options.tmp = v:true
    else
      call add(l:git_args, l:arg)

      " Handle param in next arg
      if l:arg ==# '-c' || flog#cmd#floggit#args#HasParam(l:arg) && l:arg !~# '='
        let l:arg_index += 1
        call add(l:git_args, a:args[l:arg_index])
      endif
    endif

    let l:arg_index += 1
  endwhile

  " Resolve options and return

  return {
        \ 'subcommand_index': l:arg_index >= l:nargs ? -1 : l:arg_index,
        \ 'is_subcommand': l:arg_index == l:nargs - 1,
        \ 'subcommand': l:subcommand,
        \ 'git_args': l:git_args,
        \ 'focus': l:options.focus,
        \ 'update': l:options.update,
        \ 'tmp': l:options.tmp,
        \ }
endfunction

function! flog#cmd#floggit#args#CompleteOpts(arg_lead, cmd_line, cursor_pos) abort
  return flog#args#FilterCompletions(a:arg_lead,
        \ ['-f', '-u', '-t', '--focus', '--update', '--tmp'])
endfunction

function! flog#cmd#floggit#args#CompleteCommitRefs(commit) abort
  let l:completions = []

  for l:ref in flog#state#GetCommitRefs(a:commit)
    if !empty(l:ref.remote)
      " Add remote
      let l:remote = l:ref.prefix . l:ref.remote
      if index(l:completions, l:remote) < 0
        call add(l:completions, l:remote)
      endif

      " Add remote branch
      if index(l:completions, l:ref.full) < 0
        call add(l:completions, l:ref.full)
      endif

      " Add local branch
      if index(l:completions, l:ref.tail) < 0
        call add(l:completions, l:ref.tail)
      endif
    elseif index(l:completions, l:ref.full) < 0
      " Add special/tag/branch
      call add(l:completions, l:ref.full)
    endif

    " Add original path
    if !empty(l:ref.orig)
      call add(l:completions, l:ref.orig)
    endif
  endfor

  return l:completions
endfunction

function! flog#cmd#floggit#args#CompleteContext(arg_lead, cmd_line, cursor_pos) abort
  let l:line = line('.')
  let l:firstline = line("'<")
  let l:lastline = line("'>")

  let l:is_range = (l:line == l:firstline || l:line == l:lastline) && l:firstline != l:lastline
  let l:first_commit = {}
  let l:last_commit = {}

  if l:is_range
    let l:first_commit = flog#floggraph#commit#GetAtLine(l:firstline)
    let l:last_commit = flog#floggraph#commit#GetAtLine(l:lastline)
    let l:is_range = l:first_commit != l:last_commit
  endif

  let l:completions = []

  if l:is_range
    " Complete range

    let l:has_first = !empty(l:first_commit)
    let l:has_last = !empty(l:last_commit)

    if l:has_first
      call add(l:completions, l:first_commit.hash)
    endif

    if l:has_last
      call add(l:completions, l:last_commit.hash)
    endif

    if l:has_first && l:has_last
      call add(l:completions, l:last_commit.hash . '^..' . l:first_commit.hash)
    endif

    if l:has_first
      let l:completions += flog#cmd#floggit#args#CompleteCommitRefs(l:first_commit)
      if l:has_last
        let l:last_completions = flog#cmd#floggit#args#CompleteCommitRefs(l:last_commit)
        let l:completions += flog#list#Exclude(l:last_completions, l:completions)
      endif
    else
      let l:completions += flog#cmd#floggit#args#CompleteCommitRefs(l:last_commit)
    endif

    return l:completions
  else
    " Complete single line

    let l:commit = flog#floggraph#commit#GetAtLine('.')
    if empty(l:commit)
      return []
    endif
    let l:completions = [l:commit.hash] + flog#cmd#floggit#args#CompleteCommitRefs(l:commit)
  endif

  let l:completions = flog#args#FilterCompletions(a:arg_lead, l:completions)
  return l:completions
endfunction

function! flog#cmd#floggit#args#Complete(arg_lead, cmd_line, cursor_pos) abort
  let l:is_flog = flog#floggraph#buf#IsFlogBuf()
  let l:has_state = flog#state#HasBufState()

  let l:parsed_args = flog#cmd#floggit#args#Parse(
        \ split(a:cmd_line[ : a:cursor_pos], '\s', v:true)[1 :])

  let l:fugitive_completions = flog#fugitive#Complete(
        \ flog#shell#Escape(a:arg_lead), a:cmd_line, a:cursor_pos)

  " Complete subcommand args only
  if l:parsed_args.is_subcommand
    return l:fugitive_completions
  endif

  " Complete Floggit options and Git base args
  if l:parsed_args.subcommand_index < 0
    if l:is_flog
      let l:opt_completions = flog#cmd#floggit#args#CompleteOpts(
            \ a:arg_lead, a:cmd_line, a:cursor_pos)
      return opt_completions + l:fugitive_completions
    else
      return l:fugitive_completions
    endif
  endif

  let l:completions = []

  " Complete line
  if l:is_flog
    let l:completions += flog#shell#EscapeList(
          \ flog#cmd#floggit#args#CompleteContext(a:arg_lead, a:cmd_line, a:cursor_pos))
  endif

  " Complete state
  if l:has_state
    let l:opts = flog#state#GetBufState().opts

    if !empty(l:opts.limit)
      let [l:range, l:path] = flog#args#SplitGitLimitArg(l:opts.limit)
      let l:paths = flog#args#FilterCompletions(a:arg_lead, [l:path])
      let l:paths = flog#shell#EscapeList(l:paths)
      let l:completions += flog#list#Exclude(l:paths, l:completions)
    endif

    if !empty(l:opts.path)
      let l:paths = flog#FilterCompletions(a:arg_lead, l:opts.paths)
      let l:paths = flog#shell#EscapeList(l:paths)
      let l:completions += flog#list#Exclude(l:paths, l:completions)
    endif
  endif

  " Complete Fugitive
  let l:completions += flog#list#Exclude(l:fugitive_completions, l:completions)

  return l:completions
endfunction
