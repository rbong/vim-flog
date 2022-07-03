"
" This file contains functions for handling args to the ":Floggit" command.
"

function! flog#cmd#flog_git#args#Parse(arg_lead, cmd_line, cursor_pos) abort
  let l:split_args = split(a:cmd_line[ : a:cursor_pos], '\s', v:true)
  let l:nargs = len(l:split_args)

  " Find command

  let l:command_index = 1
  let l:command = ''
  while l:command_index < l:nargs
    let l:arg = l:split_args[l:command_index]

    if !empty(l:arg) && l:arg[0] !=# '-'
      let l:command = l:arg
      break
    endif

    let l:command_index += 1
  endwhile

  " Return

  let l:is_command = v:false

  if l:command_index == l:nargs
    let l:command_index = -1
  elseif l:command_index == l:nargs - 1
    let l:is_command = v:true
  endif

  return [l:split_args, l:command_index, l:command, l:is_command]
endfunction

function! flog#cmd#flog_git#args#CompleteCommitRefs(commit) abort
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

function! flog#cmd#flog_git#args#CompleteFlog(arg_lead, cmd_line, cursor_pos) abort
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
      let l:completions += flog#cmd#flog_git#args#CompleteCommitRefs(l:first_commit)
      if l:has_last
        let l:last_completions = flog#cmd#flog_git#args#CompleteCommitRefs(l:last_commit)
        let l:completions += flog#list#Exclude(l:last_completions, l:completions)
      endif
    else
      let l:completions += flog#cmd#flog_git#args#CompleteCommitRefs(l:last_commit)
    endif

    return l:completions
  else
    " Complete single line

    let l:commit = flog#floggraph#commit#GetAtLine('.')
    if empty(l:commit)
      return []
    endif
    let l:completions = [l:commit.hash] + flog#cmd#flog_git#args#CompleteCommitRefs(l:commit)
  endif

  let l:completions = flog#args#FilterCompletions(a:arg_lead, l:completions)
  return l:completions
endfunction

function! flog#cmd#flog_git#args#Complete(arg_lead, cmd_line, cursor_pos) abort
  let l:is_flog = flog#floggraph#buf#IsFlogBuf()
  let l:has_state = flog#state#HasBufState()

  let [_, l:command_index, l:command, l:is_command] = flog#cmd#flog_git#args#Parse(
        \ a:arg_lead, a:cmd_line, a:cursor_pos)

  let l:fugitive_completions = flog#fugitive#Complete(
        \ flog#shell#Escape(a:arg_lead), a:cmd_line, a:cursor_pos)

  " Complete git/command args only
  if l:is_command || l:command_index < 0
    return l:fugitive_completions
  endif

  let l:completions = []

  " Complete line
  if l:is_flog
    let l:completions += flog#shell#EscapeList(
          \ flog#cmd#flog_git#args#CompleteFlog(a:arg_lead, a:cmd_line, a:cursor_pos))
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
