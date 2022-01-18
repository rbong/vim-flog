vim9script

#
# This file contains functions for handling args to the ":Floggit" command.
#

def flog#cmd#flog_git#args#parse(arg_lead: string, cmd_line: string, cursor_pos: number): list<any>
  const split_args = split(cmd_line[ : cursor_pos], '\s', true)
  const nargs = len(split_args)

  # Find command

  var command_index = 1
  var command = ''
  while command_index < nargs
    const arg = split_args[command_index]

    if !empty(arg) && arg[0] != '-'
      command = arg
      break
    endif

    command_index += 1
  endwhile

  # Return

  var is_command = false

  if command_index == nargs
    command_index = -1
  elseif command_index == nargs - 1
    is_command = true
  endif

  return [split_args, command_index, command, is_command]
enddef

def flog#cmd#flog_git#args#complete_commit_refs(commit: dict<any>): list<string>
  var completions = []

  for ref in flog#state#get_commit_refs(commit)
    if !empty(ref.remote)
      # Add remote
      const remote = ref.prefix .. ref.remote
      if index(completions, remote) < 0
        add(completions, remote)
      endif

      # Add remote branch
      add(completions, ref.full)

      # Add local branch
      if index(completions, ref.tail) < 0
        add(completions, ref.tail)
      endif
    else
      # Add special/tag/branch
      add(completions, ref.full)
    endif

    # Add original path
    if !empty(ref.orig)
      add(completions, ref.orig)
    endif
  endfor

  return completions
enddef

def flog#cmd#flog_git#args#complete_flog(arg_lead: string, cmd_line: string, cursor_pos: number): list<string>
  const line = line('.')
  const firstline = line("'<")
  const lastline = line("'>")

  var is_range = (line == firstline || line == lastline) && firstline != lastline
  var first_commit = {}
  var last_commit = {}

  if is_range
    first_commit = flog#floggraph#commit#get_at_line(firstline)
    last_commit = flog#floggraph#commit#get_at_line(lastline)
    is_range = first_commit != last_commit
  endif

  var completions = []

  if is_range
    # Complete range

    const has_first = !empty(first_commit)
    const has_last = !empty(last_commit)

    if has_first
      add(completions, first_commit.hash)
    endif

    if has_last
      add(completions, last_commit.hash)
    endif

    if has_first
      completions += flog#cmd#flog_git#args#complete_commit_refs(first_commit)
      if has_last
        var last_completions = flog#cmd#flog_git#args#complete_commit_refs(last_commit)
        completions += flog#list#exclude(last_completions, completions)
      endif
    else
      completions += flog#cmd#flog_git#args#complete_commit_refs(last_commit)
    endif

    return completions
  else
    # Complete single line

    const commit = flog#floggraph#commit#get_at_line('.')
    if empty(commit)
      return []
    endif
    completions = [commit.hash] + flog#cmd#flog_git#args#complete_commit_refs(commit)
  endif

  return flog#args#filter_completions(arg_lead, completions)
enddef

def flog#cmd#flog_git#args#complete(arg_lead: string, cmd_line: string, cursor_pos: number): list<string>
  const is_flog = flog#floggraph#buf#is_flog_buf()
  const has_state = flog#state#has_buf_state()

  const [_, command_index, command, is_command] = flog#cmd#flog_git#args#parse(arg_lead, cmd_line, cursor_pos)

  const fugitive_completions = flog#fugitive#complete(arg_lead, cmd_line, cursor_pos)

  # Complete git/command args only
  if is_command || command_index < 0
    return fugitive_completions
  endif

  var completions = []

  # Complete line
  if is_flog
    completions += flog#cmd#flog_git#args#complete_flog(arg_lead, cmd_line, cursor_pos)
  endif

  # Complete state
  if has_state
    const opts = flog#state#get_buf_state().opts

    if !empty(opts.limit)
      const [range, path] = flog#args#split_git_limit_arg(opts.limit)
      var paths = flog#args#filter_completions(arg_lead, [path])
      paths = flog#shell#escape_list(paths)
      completions += flog#list#exclude(paths, completions)
    endif

    if !empty(opts.path)
      var paths = flog#filter_completions(arg_lead, opts.paths)
      paths = flog#shell#escape_list(paths)
      completions += flog#list#exclude(paths, completions)
    endif
  endif

  # Complete fugitive
  completions += flog#list#exclude(fugitive_completions, completions)

  return completions
enddef
