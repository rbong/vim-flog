vim9script

#
# This file contains functions for handling args to the ":Flog" command.
#

# Parse ":Flog" args into the options object.
def flog#cmd#flog#args#parse(current_opts: dict<any>, workdir: string, args: list<string>): dict<any>
  const defaults = flog#state#get_internal_default_opts()

  var has_set_path = false

  var has_set_rev = false

  var has_set_raw_args = false
  var got_raw_args_token = false
  var raw_args = []

  for arg in args
    if got_raw_args_token
      has_set_raw_args = true
      raw_args += [arg]
    elseif arg == '--'
      got_raw_args_token = true
    elseif arg =~ '^-format=.\+'
      current_opts.format = flog#args#parse_arg(arg)
    elseif arg == '-format='
      current_opts.format = defaults.format
    elseif arg =~ '^-date=.\+'
      current_opts.date = flog#args#parse_arg(arg)
    elseif arg == '-date='
      current_opts.date = defaults.date
    elseif arg =~ '^-raw-args=.\+'
      has_set_raw_args = true
      raw_args += [flog#args#parse_arg(arg)]
    elseif arg == '-raw-args='
      has_set_raw_args = false
      current_opts.raw_args = defaults.raw_args
    elseif arg == '-all'
      current_opts.all = true
    elseif arg == '-no-all'
      current_opts.all = false
    elseif arg == '-bisect'
      current_opts.bisect = true
    elseif arg == '-no-bisect'
      current_opts.bisect = false
    elseif arg == '-merges'
      current_opts.merges = true
    elseif arg == '-no-merges'
      current_opts.merges = false
    elseif arg == '-reflog'
      current_opts.reflog = true
    elseif arg == '-no-reflog'
      current_opts.reflog = false
    elseif arg == '-reverse'
      current_opts.reverse = true
    elseif arg == '-no-reverse'
      current_opts.reverse = false
    elseif arg == '-graph'
      current_opts.graph = true
    elseif arg == '-no-graph'
      current_opts.graph = false
    elseif arg == '-patch'
      current_opts.patch = true
    elseif arg == '-no-patch'
      current_opts.patch = false
    elseif arg =~ '^-skip=\d\+'
      current_opts.skip = flog#args#parse_arg(arg)
    elseif arg == '-skip='
      current_opts.skip = defaults.skip
    elseif arg =~ '^-sort=.\+'
      current_opts.sort = flog#args#parse_arg(arg)
    elseif arg == '-sort='
      current_opts.sort = defaults.sort
    elseif arg =~ '^-max-count=\d\+'
      current_opts.max_count = flog#args#parse_arg(arg)
    elseif arg == '-max-count='
      current_opts.max_count = defaults.max_count
    elseif arg =~ '^-open-cmd=.\+'
      current_opts.open_cmd = flog#args#parse_arg(arg)
    elseif arg == '-open-cmd='
      current_opts.open_cmd = defaults.open_cmd
    elseif arg =~ '^-search=.\+'
      current_opts.search = flog#args#parse_arg(arg)
    elseif arg == '-search='
      current_opts.search = defaults.search
    elseif arg =~ '^-patch-search=.\+'
      current_opts.patch_search = flog#args#parse_arg(arg)
    elseif arg == '-patch-search='
      current_opts.patch_search = defaults.patch_search
    elseif arg =~ '^-author=.\+'
      current_opts.author = flog#args#parse_arg(arg)
    elseif arg == '-author='
      current_opts.author = defaults.author
    elseif arg =~ '^-limit=.\+'
      current_opts.limit = flog#args#parse_git_limit_arg(workdir, arg)
    elseif arg == '-limit='
      current_opts.limit = defaults.limit
    elseif arg =~ '^-rev=.\+'
      if !has_set_rev
        current_opts.rev = []
        has_set_rev = true
      endif
      add(current_opts.rev, flog#args#parse_arg(arg))
    elseif arg == '-rev='
      has_set_rev = false
      current_opts.rev = defaults.rev
    elseif arg =~ '^-path=.\+'
      if !has_set_path
        current_opts.path = []
        has_set_path = true
      endif
      add(current_opts.path, flog#args#parse_git_path_arg(workdir, arg))
    elseif arg == '-path='
      current_opts.path = defaults.path
      has_set_path = false
    else
      echoerr 'error parsing argument ' .. arg
      throw g:flog_unsupported_argument
    endif
  endfor

  if has_set_raw_args
    current_opts.raw_args = join(raw_args, ' ')
  endif

  return current_opts
enddef

def flog#cmd#flog#args#complete_format(arg_lead: string): list<string>
  var is_escaped = false
  var current_specifier = ''
  var current_parens = ''

  # Find last specifier (handles escaped % signs)
  for c in arg_lead
    if c == '%'
      if current_specifier == '%'
        # Literal percent
        current_specifier = '%%'
      else
        # New specifier
        current_specifier = '%'
        current_parens = ''
      endif
    elseif current_specifier == ''
      continue
    elseif current_specifier == '%%'
      current_specifier = ''
      current_parens = ''
    elseif current_specifier =~ '($'
      if c == ')'
        # End of parens/specifier
        current_specifier = ''
        current_parens = ''
      else
        # Inside parens
        current_parens ..= c
      endif
    else
      current_specifier ..= c
    endif
  endfor

  # Inside of parens, end parens
  if !empty(current_parens)
    return [arg_lead .. ')']
  endif

  const completions = []
  const l = len(current_specifier)

  # Find specifiers that start with the current specifier
  if l > 0
    const prefix = arg_lead[ : -l - 1]

    for specifier in g:flog_format_specifiers
      if stridx(specifier, current_specifier) == 0
        add(completions, prefix .. specifier)
      endif
    endfor
  endif

  # No specifier, start a new one
  if empty(completions)
    return [arg_lead .. '%']
  endif

  return completions
enddef

def flog#cmd#flog#args#complete_date(arg_lead: string): list<string>
  const [lead, _] = flog#args#split_arg(arg_lead)
  var completions = map(copy(g:flog_date_formats), (_, val) => lead .. val)
  return flog#args#filter_completions(arg_lead, completions)
enddef

def flog#cmd#flog#args#complete_open_cmd(arg_lead: string): list<string>
  const [lead, _] = flog#args#split_arg(arg_lead)

  var completions = g:flog_open_cmds + g:flog_open_cmd_modifiers

  # Add combined open commands
  for modifier in g:flog_open_cmd_modifiers
    for open_cmd in g:flog_open_cmds
      add(completions, modifier .. ' ' .. open_cmd)
    endfor
  endfor

  completions = flog#args#escape_completions(lead, completions)

  return flog#args#filter_completions(arg_lead, completions)
enddef

def flog#cmd#flog#args#complete_author(arg_lead: string): list<string>
  if !flog#fugitive#is_fugitive_buffer()
    return []
  endif

  const [lead, _] = flog#args#split_arg(arg_lead)
  var completions = flog#git#get_authors()
  return flog#args#filter_completions(
    arg_lead,
    flog#args#escape_completions(lead, completions)
  )
enddef

def flog#cmd#flog#args#complete_limit(arg_lead: string): list<string>
  const [lead, limit] = flog#args#split_arg(arg_lead)

  var [range, path] = flog#args#split_git_limit_arg(limit)
  if range !~ ':$'
    return []
  endif
  path = flog#args#unescape_arg(path)

  var completions = getcompletion(path, 'file')
  completions = flog#args#escape_completions(lead .. range, completions)
  return flog#args#filter_completions(arg_lead, completions)
enddef

def flog#cmd#flog#args#complete_rev(arg_lead: string): list<string>
  if !flog#fugitive#is_fugitive_buffer()
    return []
  endif
  const [lead, _] = flog#args#split_arg(arg_lead)

  var refs = flog#git#get_refs()

  var completions = flog#args#escape_completions(lead, refs)
  return flog#args#filter_completions(arg_lead, completions)
enddef

def flog#cmd#flog#args#complete_path(arg_lead: string): list<string>
  var [lead, path] = flog#args#split_arg(arg_lead)
  path = flog#args#unescape_arg(path)

  var files = getcompletion(path, 'file')

  var completions = flog#args#escape_completions(lead, files)
  return flog#args#filter_completions(arg_lead, completions)
enddef

def flog#cmd#flog#args#complete_sort(arg_lead: string): list<string>
  const [lead, _] = flog#args#split_arg(arg_lead)

  var sort_types = []
  for sort_type in g:flog_sort_types
    add(sort_types, sort_type.name)
  endfor

  var completions = flog#args#escape_completions(lead, sort_types)
  return flog#args#filter_completions(arg_lead, completions)
enddef

def flog#cmd#flog#args#complete(arg_lead: string, cmd_line: string, cursor_pos: number): list<string>
  if cmd_line[ : cursor_pos] =~ ' -- '
    return []
  endif

  const default_completion = [
    '-all ',
    '--no-all ',
    '-author=',
    '-bisect ',
    '-no-bisect ',
    '-date=',
    '-format=',
    '-graph ',
    '-no-graph ',
    '-limit=',
    '-max-count=',
    '-merges ',
    '-no-merges ',
    '-open-cmd=',
    '-patch ',
    '-no-patch ',
    '-patch-search=',
    '-path=',
    '-raw-args=',
    '-reflog ',
    '-no-reflog ',
    '-rev=',
    '-reverse ',
    '-no-reverse ',
    '-search=',
    '-skip=',
    '-sort=',
    ]

  if arg_lead == ''
    return flog#args#filter_completions(arg_lead, default_completion)
  elseif arg_lead =~ '^-format='
    return flog#cmd#flog#args#complete_format(arg_lead)
  elseif arg_lead =~ '^-date='
    return flog#cmd#flog#args#complete_date(arg_lead)
  elseif arg_lead =~ '^-open-cmd='
    return flog#cmd#flog#args#complete_open_cmd(arg_lead)
  elseif arg_lead =~ '^-\(patch-\)\?search='
    return []
  elseif arg_lead =~ '^-author='
    return flog#cmd#flog#args#complete_author(arg_lead)
  elseif arg_lead =~ '^-limit='
    return flog#cmd#flog#args#complete_limit(arg_lead)
  elseif arg_lead =~ '^-rev='
    return flog#cmd#flog#args#complete_rev(arg_lead)
  elseif arg_lead =~ '^-path='
    return flog#cmd#flog#args#complete_path(arg_lead)
  elseif arg_lead =~ '^-sort='
    return flog#cmd#flog#args#complete_sort(arg_lead)
  endif
  return flog#args#filter_completions(arg_lead, default_completion)
enddef
