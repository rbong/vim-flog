" Utilities {{{

function! flog#instance() abort
  let l:instance = g:flog_instance_counter
  let g:flog_instance_counter += 1
  return l:instance
endfunction

function! flog#get_all_window_ids() abort
  let l:tabs = gettabinfo()
  let l:windows = []
  for l:tab in l:tabs
    let l:windows += l:tab.windows
  endfor
  return l:windows
endfunction

function! flog#exclude(list, filters) abort
  return filter(a:list, 'index(a:filters, v:val) < 0')
endfunction

function! flog#ellipsize(string, ...) abort
  let l:max_len = a:0 >= 1 ? min(a:1, 4) : 15
  let l:dir = a:0 >= 2 ? a:2 : 0

  if len(a:string) > l:max_len
    if l:dir == 0
      return a:string[: l:max_len - 4] . '...'
    else
      return '...' . a:string[l:max_len - 3 :]
    endif
  else
    return a:string
  endif
endfunction

function! flog#unescape_arg(arg) abort
  let l:arg = ''
  let l:is_escaped = 0

  for l:char in split(a:arg, '\zs')
    if l:char ==# '\' && !l:is_escaped
      let l:is_escaped = 1
    else
      let l:arg .= l:char
      let l:is_escaped = 0
    endif
  endfor

  return l:arg
endfunction

function! flog#resolve_path(path, relative_dir) abort
  let l:full_path = fnamemodify(a:path, ':p')
  if stridx(l:full_path, a:relative_dir) == 0
    return l:full_path[len(a:relative_dir) + 1:]
  endif
  return a:path
endfunction

function! flog#split_limit(limit) abort
  let [l:match, l:start, l:end] = matchstrpos(a:limit, '^.\{1}:\zs')
  if l:start < 0
    return [a:limit, '']
  endif
  return [a:limit[: l:start - 1], a:limit[l:start :]]
endfunction

function! flog#get_sort_type(name) abort
  return filter(copy(g:flog_sort_types), 'v:val.name ==# ' . string(a:name))[0]
endfunction

function! flog#get(dict, key, ...) abort
  if type(a:dict) != v:t_dict
    return v:null
  endif
  let l:default = get(a:, 1, v:null)
  return get(a:dict, a:key, l:default)
endfunction

" }}}

" Deprecation helpers {{{

function! flog#show_deprecation_warning(deprecated_usage, new_usage) abort
  echoerr printf('Deprecated: %s', a:deprecated_usage)
  echoerr printf('New usage: %s', a:new_usage)
  let g:flog_shown_deprecation_warnings[a:deprecated_usage] = 1
endfunction

function! flog#did_show_deprecation_warning(deprecated_usage) abort
  return has_key(g:flog_shown_deprecation_warnings, a:deprecated_usage)
endfunction

function! flog#deprecate_mapping(mapping, new_mapping, ...) abort
  let l:deprecated_usage = a:mapping
  if hasmapto(a:mapping) && !flog#did_show_deprecation_warning(l:deprecated_usage)
    let l:new_mapping_type = get(a:, 1, '{nmap|vmap}')
    let l:new_mapping_value = get(a:, 2, '...')
    let l:new_usage = printf('%s %s %s', l:new_mapping_type, l:new_mapping_value, a:new_mapping)
    return flog#show_deprecation_warning(l:deprecated_usage, l:new_usage)
  endif
endfunction

function! flog#deprecate_setting(setting, new_setting, ...) abort
  let l:deprecated_usage = a:setting
  if exists(a:setting) && !flog#did_show_deprecation_warning(l:deprecated_usage)
    let l:new_setting_value = get(a:, 1, '...')
    let l:new_usage = printf('let %s = %s', a:new_setting, l:new_setting_value)
    return flog#show_deprecation_warning(l:deprecated_usage, l:new_usage)
  endif
endfunction

function! flog#deprecate_function(func, new_func, ...) abort
  let l:deprecated_usage = printf('%s()', a:func)
  let l:new_func_args = get(a:, 1, '...')
  let l:new_usage = printf('call %s(%s)', a:new_func, l:new_func_args)

  if !flog#did_show_deprecation_warning(l:deprecated_usage)
    let l:new_func_args = get(a:, 1, '...')
    let l:new_usage = printf('call %s(%s)', a:new_func, l:new_func_args)
    call flog#show_deprecation_warning(l:deprecated_usage, l:new_usage)
  endif
endfunction

function! flog#deprecate_autocmd(autocmd, new_autocmd) abort
  let l:deprecated_usage = a:autocmd
  if exists('#' . a:autocmd) && !flog#did_show_deprecation_warning(l:deprecated_usage)
    let l:new_usage = printf('autocmd %s ...', a:new_autocmd)
    call flog#show_deprecation_warning(l:deprecated_usage, l:new_usage)
  endif
endfunction

function! flog#deprecate_command(command, new_command, ...) abort
  let l:deprecated_usage = a:command
  if !flog#did_show_deprecation_warning(l:deprecated_usage)
    let l:new_command_args = get(a:, 1, '...')
    let l:new_usage = printf('%s %s', a:new_command, l:new_command_args)
    call flog#show_deprecation_warning(l:deprecated_usage, l:new_usage)
  endif
endfunction

" }}}

" Shell interface {{{

function! flog#systemlist(command) abort
  let l:output = systemlist(a:command)
  if v:shell_error
    echoerr join(l:output, "\n")
    throw g:flog_shell_error
  endif
  return l:output
endfunction

" }}}

" Fugitive interface {{{

function! flog#is_fugitive_buffer() abort
  try
    call fugitive#repo()
  catch /not a Git repository/
    return v:false
  endtry
  return v:true
endfunction

function! flog#resolve_fugitive_path_arg(path) abort
  return flog#resolve_path(a:path, fugitive#repo().tree())
endfunction

function! flog#get_initial_fugitive_repo() abort
  return fugitive#repo()
endfunction

function! flog#get_fugitive_workdir() abort
  let l:tree = flog#get_state().fugitive_repo.tree()
  return l:tree
endfunction

function! flog#get_fugitive_git_command() abort
  let l:git_command = FugitiveShellCommand()
  return l:git_command
endfunction

function! flog#get_fugitive_git_dir() abort
  return flog#get_state().fugitive_repo.git_dir
endfunction

function! flog#trigger_fugitive_git_detection() abort
  let b:git_dir = flog#get_state().fugitive_repo.dir()
  let l:workdir = flog#get_fugitive_workdir()
  call FugitiveDetect(l:workdir)
endfunction

" }}}

" Argument handling {{{

" Argument parsing {{{

function! flog#get_internal_default_args() abort
  let l:defaults = {
        \ 'raw_args': v:null,
        \ 'format': '%Cblue%ad%Creset %C(yellow)[%h]%Creset %Cgreen{%an}%Creset%Cred%d%Creset %s',
        \ 'date': 'iso8601',
        \ 'all': v:false,
        \ 'bisect': v:false,
        \ 'no_merges': v:false,
        \ 'reflog': v:false,
        \ 'reverse': v:false,
        \ 'no_graph': v:false,
        \ 'no_patch': v:false,
        \ 'skip': v:null,
        \ 'sort': v:null,
        \ 'max_count': v:null,
        \ 'open_cmd': 'tabedit',
        \ 'search': v:null,
        \ 'patch_search': v:null,
        \ 'author': v:null,
        \ 'limit': v:null,
        \ 'rev': [],
        \ 'path': []
        \ }

  " read the user immutable defaults
  if exists('g:flog_permanent_default_arguments')
    for [l:key, l:value] in items(g:flog_permanent_default_arguments)
      if has_key(l:defaults, l:key)
        let l:defaults[l:key] = l:value
      else
        echoerr 'Warning: unrecognized immutable argument ' . l:key
      endif
    endfor
  endif

  return l:defaults
endfunction

function! flog#get_default_args() abort
  let l:new_settings = '{g:flog_default_arguments|g:flog_permanent_default_arguments}'
  call flog#deprecate_setting('g:flog_default_format', l:new_settings, '{ "format": ... }')
  call flog#deprecate_setting('g:flog_default_date_format', l:new_settings, '{ "date": ... }')

  let l:defaults = flog#get_internal_default_args()

  " read the user argument defaults
  if exists('g:flog_default_arguments')
    for [l:key, l:value] in items(g:flog_default_arguments)
      if has_key(l:defaults, l:key)
        let l:defaults[l:key] = l:value
      else
        echoerr 'Warning: unrecognized default argument ' . l:key
      endif
    endfor
  endif

  return l:defaults
endfunction

function! flog#parse_arg_opt(arg) abort
  let l:opt = matchstr(a:arg, '=\zs.*')
  return l:opt
endfunction

function! flog#parse_limit_opt(arg) abort
  let l:arg = flog#parse_arg_opt(a:arg)
  let [l:limit, l:path] = flog#split_limit(l:arg)
  if l:path ==# ''
    return l:arg
  endif
  return l:limit . fnameescape(flog#resolve_fugitive_path_arg(l:path))
endfunction

function! flog#parse_path_opt(arg) abort
  return [fnameescape(flog#resolve_fugitive_path_arg(expand(flog#parse_arg_opt(a:arg))))]
endfunction

function! flog#parse_set_args(args, current_args, defaults) abort
  let l:has_set_path = v:false

  let l:has_set_rev = v:false

  let l:has_set_raw_args = v:false
  let l:got_raw_args_token = v:false
  let l:raw_args = []

  for l:arg in a:args
    if l:got_raw_args_token
      let l:has_set_raw_args = v:true
      let l:raw_args += [l:arg]
    elseif l:arg ==# '--'
      let l:got_raw_args_token = v:true
    elseif l:arg =~# '^-format=.\+'
      let a:current_args.format = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-format='
      let a:current_args.format = a:defaults.format
    elseif l:arg =~# '^-date=.\+'
      let a:current_args.date = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-date='
      let a:current_args.date = a:defaults.date
    elseif l:arg =~# '^-raw-args=.\+'
      let l:has_set_raw_args = v:true
      let l:raw_args += [flog#parse_arg_opt(l:arg)]
    elseif l:arg ==# '-raw-args='
      let l:has_set_raw_args = v:false
      let a:current_args.raw_args = a:defaults.raw_args
    elseif l:arg ==# '-all'
      let a:current_args.all = v:true
    elseif l:arg ==# '-bisect'
      let a:current_args.bisect = v:true
    elseif l:arg ==# '-no-merges'
      let a:current_args.no_merges = v:true
    elseif l:arg ==# '-reflog'
      let a:current_args.reflog = v:true
    elseif l:arg ==# '-reverse'
      let a:current_args.reverse = v:true
    elseif l:arg ==# '-no-graph'
      let a:current_args.no_graph = v:true
    elseif l:arg ==# '-no-patch'
      let a:current_args.no_patch = v:true
    elseif l:arg =~# '^-skip=\d\+'
      let a:current_args.skip = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-skip='
      let a:current_args.skip = a:defaults.skip
    elseif l:arg =~# '^-sort=.\+'
      let a:current_args.sort = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-sort='
      let a:current_args.sort = a:defaults.sort
    elseif l:arg =~# '^-max-count=\d\+'
      let a:current_args.max_count = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-max-count='
      let a:current_args.max_count = a:defaults.max_count
    elseif l:arg =~# '^-open-cmd=.\+'
      let a:current_args.open_cmd = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-open-cmd='
      let a:current_args.open_cmd = a:defaults.open_cmd
    elseif l:arg =~# '^-search=.\+'
      let a:current_args.search = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-search='
      let a:current_args.search = a:defaults.search
    elseif l:arg =~# '^-patch-search=.\+'
      let a:current_args.patch_search = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-patch-search='
      let a:current_args.patch_search = a:defaults.patch_search
    elseif l:arg =~# '^-author=.\+'
      let a:current_args.author = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-author='
      let a:current_args.author = a:defaults.author
    elseif l:arg =~# '^-limit=.\+'
      let a:current_args.limit = flog#parse_limit_opt(l:arg)
    elseif l:arg ==# '-limit='
      let a:current_args.limit = a:defaults.limit
    elseif l:arg =~# '^-rev=.\+'
      if !l:has_set_rev
        let a:current_args.rev = []
        let l:has_set_rev = v:true
      endif
      let a:current_args.rev += [flog#parse_arg_opt(l:arg)]
    elseif l:arg ==# '-rev='
      let l:has_set_rev = v:false
      let a:current_args.rev = a:defaults.rev
    elseif l:arg =~# '^-path=.\+'
      if !l:has_set_path
        let a:current_args.path = []
        let l:has_set_path = v:true
      endif
      let a:current_args.path += flog#parse_path_opt(l:arg)
    elseif l:arg ==# '-path='
      let a:current_args.path = a:defaults.path
      let l:has_set_path = v:false
    else
      echoerr 'error parsing argument ' . l:arg
      throw g:flog_unsupported_argument
    endif
  endfor

  if l:has_set_raw_args
    let a:current_args.raw_args = join(l:raw_args, ' ')
  endif

  return a:current_args
endfunction

function! flog#parse_args(args) abort
  return flog#parse_set_args(a:args, flog#get_default_args(), flog#get_internal_default_args())
endfunction

" }}}

" Argument completion {{{

" Argument completion utilities {{{

function! flog#filter_completions(arg_lead, completions) abort
  let l:lead = escape(a:arg_lead, '\\')
  return filter(a:completions, 'v:val =~# "^" . l:lead')
endfunction

function! flog#escape_completions(lead, completions) abort
  return map(a:completions, "a:lead . substitute(v:val, ' ', '\\\\ ', '')")
endfunction

function! flog#split_single_completable_arg(arg) abort
  let l:start_pattern = '^\([^=]*=\)\?'
  let l:start = matchstr(a:arg, l:start_pattern)
  let l:rest = matchstr(a:arg, l:start_pattern . '\zs.*')

  return [l:start, l:rest]
endfunction

function! flog#split_completable_arg(arg) abort
  let [l:start, l:rest ] = flog#split_single_completable_arg(a:arg)

  let l:split = split(l:rest, '\\ ', v:true)

  let l:trimmed = l:split[:-2]

  if l:split != []
    let l:last = l:split[-1]
  else
    let l:last = ''
  endif

  let l:lead = l:start . join(l:trimmed, '\ ')
  if len(l:trimmed) > 0
    let l:lead .= '\ '
  endif

  return [l:lead, l:last]
endfunction

" }}}

" Argument commands {{{

function! flog#get_remotes() abort
  return flog#systemlist(flog#get_fugitive_git_command() . ' remote')
endfunction

function! flog#get_refs() abort
  let l:command = flog#get_fugitive_git_command()
        \ . ' rev-parse --symbolic --branches --tags --remotes'
  return flog#systemlist(l:command) +  ['HEAD', 'FETCH_HEAD', 'MERGE_HEAD', 'ORIG_HEAD']
endfunction

function! flog#get_authors() abort
  let l:command = flog#get_fugitive_git_command()
        \ . ' shortlog --all --no-merges -s -n'
  " Filter author commit numbers before returning
  return map(
        \ flog#systemlist(l:command), 
        \ 'substitute(v:val, "^\\s*\\d\\+\\s*", "", "")')
endfunction

" }}}

" Git command argument completion {{{

function! flog#complete_line(arg_lead, cmd_line, cursor_pos) abort
  let l:line = line('.')
  let l:firstline = line("'<")
  let l:lastline = line("'>")

  if (l:line != l:firstline && l:line != l:lastline) || l:firstline == l:lastline
    " complete for only the current line
    let l:commit = flog#get_commit_at_line()
    if type(l:commit) != v:t_dict
      return []
    endif
    let l:completions = [l:commit.short_commit_hash]
          \ + flog#get_remotes() + l:commit.ref_name_list
  else
    " complete for a range
    let l:commit = flog#get_commit_selection(l:firstline, l:lastline)
    if type(l:commit) != v:t_list
      return []
    endif
    let l:first_commit = l:commit[0]
    let l:last_commit = l:commit[1]
    if l:first_commit == l:last_commit
      let l:completions = [l:first_commit.short_commit_hash] + l:commit.ref_name_list
    else
      let l:first_hash = l:first_commit.short_commit_hash
      let l:last_hash = l:last_commit.short_commit_hash
      let l:completions = [l:first_hash, l:last_hash]
            \ + flog#get_remotes()
            \ + l:first_commit.ref_name_list + l:last_commit.ref_name_list
            \ + [
              \ l:last_hash . '..' . l:first_hash,
              \ l:last_hash . '^..' . l:first_hash
            \ ]
    endif
  endif

  return flog#filter_completions(a:arg_lead, l:completions)
endfunction

function! flog#complete_git(arg_lead, cmd_line, cursor_pos) abort
  let l:state = flog#get_state()
  let l:split_args = split(a:cmd_line, '\s', v:true)

  " complete commands
  let l:current_arg_num = len(l:split_args)
  if l:current_arg_num <= 2
    return flog#filter_completions(a:arg_lead, copy(g:flog_git_commands))
  endif

  " complete line info
  let l:completions = flog#complete_line(a:arg_lead, a:cmd_line, a:cursor_pos)

  " complete all possible refs
  let l:completed_refs = flog#filter_completions(a:arg_lead, flog#get_refs())
  let l:completions += flog#exclude(l:completed_refs, l:completions)

  " complete limit
  if l:state.limit
    let [l:limit, l:limit_path] = flog#split_limit(l:state.limit)
    let l:completions += flog#filter_completions(a:arg_lead, [l:limit_path])
  endif

  " complete path
  let l:completions += flog#exclude(flog#filter_completions(a:arg_lead, l:state.path), l:completions)

  " complete all filenames
  let l:completions += flog#exclude(getcompletion(a:arg_lead, 'file'), l:completions)

  " complete subcommands
  let l:command = l:split_args[1]
  if l:current_arg_num == 3 && has_key(g:flog_git_subcommands, l:command)
    let l:completions += flog#filter_completions(a:arg_lead, copy(g:flog_git_subcommands[l:command]))
  endif

  return l:completions
endfunction

function! flog#complete_jump(arg_lead, cmd_line, cursor_pos) abort
  let l:state = flog#get_state()
  return flog#complete_rev(a:arg_lead)
endfunction

" }}}

" Flog command argument commpletion {{{

function! flog#complete_format(arg_lead) abort
  " build patterns
  let l:completable_pattern = g:flog_eat_specifier_pattern
        \ . '\zs%' . g:flog_completable_specifier_pattern . '\?$'
  let l:noncompletable_pattern = g:flog_eat_specifier_pattern
        \ . '\zs%' . g:flog_noncompletable_specifier_pattern . '$'

  " test the arg lead
  if a:arg_lead =~# l:noncompletable_pattern
    " format ends with an incompletable pattern
    return []
  elseif a:arg_lead =~# l:completable_pattern
    " format ends with a completable pattern
    let l:lead = substitute(a:arg_lead, l:completable_pattern, '', '')
    let l:completions = map(copy(g:flog_completion_specifiers), 'l:lead . v:val')
    return flog#filter_completions(a:arg_lead, copy(l:completions))
  else
    " format does not end with any special atom
    return [a:arg_lead . '%']
  endif
endfunction

function! flog#complete_date(arg_lead) abort
  let [l:lead, l:path] = flog#split_single_completable_arg(a:arg_lead)
  let l:completions = map(copy(g:flog_date_formats), 'l:lead . v:val')
  return flog#filter_completions(a:arg_lead, l:completions)
endfunction

function! flog#complete_open_cmd(arg_lead) abort
  " get the lead without the last command
  let [l:lead, l:last] = flog#split_completable_arg(a:arg_lead)

  " build the list of possible completions
  let l:completions = []
  let l:completions += map(copy(g:flog_open_cmd_modifiers), 'l:lead . v:val')
  let l:completions += map(copy(g:flog_open_cmds), 'l:lead . v:val')

  return flog#filter_completions(a:arg_lead, l:completions)
endfunction

function! flog#complete_limit(arg_lead) abort
  let [l:lead, l:last] = flog#split_completable_arg(a:arg_lead)

  let [l:limit, l:path] = flog#split_limit(l:last)
  if l:limit !~# '^.\{1}:$'
    return []
  endif

  let l:files = getcompletion(flog#unescape_arg(l:path), 'file')
  let l:completions = flog#escape_completions(l:lead . l:limit, l:files)

  return flog#filter_completions(a:arg_lead, l:completions)
endfunction

function! flog#complete_rev(arg_lead) abort
  if !flog#is_fugitive_buffer()
    return []
  endif
  let [l:lead, l:last] = flog#split_single_completable_arg(a:arg_lead)
  let l:refs = flog#get_refs()
  return flog#filter_completions(a:arg_lead, map(l:refs, 'l:lead . v:val'))
endfunction

function! flog#complete_path(arg_lead) abort
  let [l:lead, l:path] = flog#split_single_completable_arg(a:arg_lead)

  let l:files = getcompletion(flog#unescape_arg(l:path), 'file')
  let l:completions = flog#escape_completions(l:lead, l:files)

  return flog#filter_completions(a:arg_lead, l:completions)
endfunction

function! flog#complete_author(arg_lead) abort
  let [l:lead, l:name] = flog#split_single_completable_arg(a:arg_lead)
  let l:authors = flog#escape_completions(l:lead, flog#get_authors())
  return flog#filter_completions(a:arg_lead, l:authors)
endfunction

function! flog#complete_sort(arg_lead) abort
  let [l:lead, l:name] = flog#split_single_completable_arg(a:arg_lead)
  let l:sort_types = flog#escape_completions(l:lead, map(copy(g:flog_sort_types), 'v:val.name'))
  return flog#filter_completions(a:arg_lead, l:sort_types)
endfunction

function! flog#complete(arg_lead, cmd_line, cursor_pos) abort
  if a:cmd_line[:a:cursor_pos] =~# ' -- '
    return []
  endif

  if a:arg_lead ==# ''
    return flog#filter_completions(a:arg_lead, copy(g:flog_default_completion))
  elseif a:arg_lead =~# '^-format='
    return flog#complete_format(a:arg_lead)
  elseif a:arg_lead =~# '^-date='
    return flog#complete_date(a:arg_lead)
  elseif a:arg_lead =~# '^-open-cmd='
    return flog#complete_open_cmd(a:arg_lead)
  elseif a:arg_lead =~# '^-\(patch-\)\?search='
    return []
  elseif a:arg_lead =~# '^-author='
    return flog#complete_author(a:arg_lead)
  elseif a:arg_lead =~# '^-limit='
    return flog#complete_limit(a:arg_lead)
  elseif a:arg_lead =~# '^-rev='
    return flog#complete_rev(a:arg_lead)
  elseif a:arg_lead =~# '^-path='
    return flog#complete_path(a:arg_lead)
  elseif a:arg_lead =~# '^-sort='
    return flog#complete_sort(a:arg_lead)
  endif
  return flog#filter_completions(a:arg_lead, copy(g:flog_default_completion))
endfunction

" }}}

" }}}

" }}}

" State management {{{

function! flog#get_initial_state(parsed_args, original_file) abort
  return extend(copy(a:parsed_args), {
        \ 'instance': flog#instance(),
        \ 'fugitive_repo': flog#get_initial_fugitive_repo(),
        \ 'original_file': a:original_file,
        \ 'graph_window_id': v:null,
        \ 'tmp_window_ids': [],
        \ 'previous_log_command': v:null,
        \ 'line_commits': [],
        \ 'commit_refs': [],
        \ 'line_commit_refs': [],
        \ 'ref_line_lookup': {},
        \ 'ansi_esc_called': v:false,
        \ })
endfunction

function! flog#set_buffer_state(state) abort
  let b:flog_state = a:state
endfunction

function! flog#get_state() abort
  if !exists('b:flog_state')
    throw g:flog_missing_state
  endif
  return b:flog_state
endfunction

function! flog#get_resolved_graph_options() abort
  let l:opts = copy(flog#get_state())

  let l:opts.bisect = l:opts.bisect && !l:opts.limit
  let l:opts.reflog = l:opts.reflog && !l:opts.limit

  return l:opts
endfunction

" }}}

" Log command management {{{

function! flog#create_log_format() abort
  let l:state = flog#get_state()

  " start format
  let l:format = 'format:'
  let l:format .= g:flog_format_start

  " add data specifiers
  let l:tokens = []
  for l:specifier in g:flog_log_data_format_specifiers
    let l:tokens += [g:flog_format_specifiers[l:specifier]]
  endfor
  let l:format .= join(l:tokens, g:flog_format_separator)

  " add display specifiers
  let l:format .= g:flog_format_separator . g:flog_display_commit_start
  let l:format .= l:state.format
  let l:format .= g:flog_display_commit_end

  " end format
  let l:format .= g:flog_format_end
  " perform string formatting to avoid shell interpolation
  return shellescape(l:format)
endfunction

function! flog#parse_log_commit(c) abort
  let l:i = stridx(a:c, g:flog_format_start)
  if l:i < 0
    return {}
  endif
  let l:j = stridx(a:c, g:flog_display_commit_start)
  let l:k = stridx(a:c, g:flog_display_commit_end)
  let l:l = stridx(a:c, g:flog_format_end)

  let l:dat = split(a:c[l:i + len(g:flog_format_start) : l:j - 1], g:flog_format_separator, v:true)

  let l:c = {}

  let l:c.short_commit_hash = l:dat[g:flog_log_data_hash_index]
  let l:c.ref_names_unwrapped = l:dat[g:flog_log_data_ref_index]
  let l:c.internal_data = l:dat

  let l:c.ref_name_list = split(l:c.ref_names_unwrapped, ' -> \|, \|tag: ')

  let l:end = a:c[l:l  + len(g:flog_format_end):]
  if l:end !=# '' && l:end[0] !=# "\n"
    let l:end = "\n" . l:end
  endif
  let l:c.display = split(
        \ (l:i == 0 ? '' : a:c[0 : l:i - 1])
        \ . a:c[l:j + len(g:flog_display_commit_start) : l:k - 1]
        \ . l:end,
        \ "\n")

  return l:c
endfunction

function! flog#parse_log_output(output) abort
  let l:output_len = len(a:output)
  if l:output_len == 0
    return []
  endif

  let l:o = []
  let l:raw = []
  let l:i = 0

  " Group non-commit lines at the start of output with the first commit
  " See https://github.com/rbong/vim-flog/pull/14
  while l:i < l:output_len && a:output[l:i] !~# g:flog_format_start
    let l:raw += [a:output[l:i]]
    let l:i += 1
  endwhile
  if l:raw != []
    let l:raw += [a:output[l:i]]
    let l:i += 1
  endif

  while l:i < l:output_len
    let l:line = a:output[l:i]
    if l:line =~# g:flog_format_start && l:raw != []
      let l:o += [flog#parse_log_commit(join(l:raw, "\n"))]
      let l:raw = []
    endif
    let l:raw += [l:line]
    let l:i += 1
  endwhile

  if l:raw != []
      let l:o += [flog#parse_log_commit(join(l:raw, "\n"))]
  endif

  return l:o
endfunction

function! flog#build_log_paths() abort
  let l:state = flog#get_state()
  if len(l:state.path) == 0
    return ''
  endif
  let l:paths = map(l:state.path, 'fnamemodify(v:val, ":.")')
  return join(l:paths, ' ')
endfunction

function! flog#build_log_args() abort
  let l:opts = flog#get_resolved_graph_options()

  let l:args = ''

  if !l:opts.no_graph
    let l:args .= ' --graph'
  endif
  let l:args .= ' --no-color'
  let l:args .= ' --pretty=' . flog#create_log_format()
  let l:args .= ' --date=' . shellescape(l:opts.date)
  if l:opts.all && !l:opts.limit
    let l:args .= ' --all'
  endif
  if l:opts.bisect
    let l:args .= ' --bisect'
  endif
  if l:opts.no_merges
    let l:args .= ' --no-merges'
  endif
  if l:opts.reflog
    let l:args .= ' --reflog'
  endif
  if l:opts.reverse
    let l:args .= ' --reverse'
  endif
  if l:opts.no_patch
    let l:args .= ' --no-patch'
  endif
  if l:opts.skip != v:null
    let l:args .= ' --skip=' . shellescape(l:opts.skip)
  endif
  if l:opts.sort != v:null
    let l:sort_type = flog#get_sort_type(l:opts.sort)
    let l:args .= ' ' . l:sort_type.args
  endif
  if l:opts.max_count != v:null
    let l:args .= ' --max-count=' . shellescape(l:opts.max_count)
  endif
  if l:opts.search != v:null
    let l:search = shellescape(l:opts.search)
    let l:args .= ' --grep=' . l:search
  endif
  if l:opts.patch_search != v:null
    let l:patch_search = shellescape(l:opts.patch_search)
    let l:args .= ' -G' . l:patch_search
  endif
  if l:opts.author != v:null
    let l:args .= ' --author=' . shellescape(l:opts.author)
  endif
  if l:opts.limit != v:null
    let l:limit = shellescape(l:opts.limit)
    let l:args .= ' -L' . l:limit
  endif
  if l:opts.raw_args != v:null
    let l:args .= ' ' . l:opts.raw_args
  endif
  if get(g:, 'flog_use_ansi_esc')
    let l:args .= ' --color'
  endif
  if len(l:opts.rev) >= 1
    if l:opts.limit
      let l:rev = l:opts.rev[0]
    else
      let l:rev = join(l:opts.rev, ' ')
    endif
    let l:args .= ' ' . l:rev
  endif

  return l:args
endfunction

function! flog#build_log_command() abort
  let l:command = flog#get_fugitive_git_command()
  let l:command .= ' log'
  let l:command .= flog#build_log_args()
  let l:command .= ' -- '
  let l:command .= flog#build_log_paths()

  return l:command
endfunction

function! flog#get_log_display(commits) abort
  let l:o = []
  for l:c in a:commits
    let l:o += l:c.display
  endfor
  return l:o
endfunction

" }}}

" Commit operations {{{

function! flog#get_commit_at_line(...) abort
  let l:line = get(a:, 1, '.')
  if type(l:line) == v:t_string
    let l:line = line(l:line)
  endif
  return get(flog#get_state().line_commits, l:line - 1, v:null)
endfunction

function! flog#get_commit_selection(...) abort
  let l:firstline = get(a:, 1, v:null)
  let l:lastline = get(a:, 2, v:null)
  let l:should_swap = get(a:, 3, 0)

  if type(l:firstline) != v:t_string && type(l:firstline) != v:t_number
    let l:firstline = "'<"
  endif

  if type(l:lastline) != v:t_string && type(l:lastline) != v:t_number
    let l:lastline = "'>"
  endif

  let l:first_commit = flog#get_commit_at_line(l:firstline)

  if type(l:first_commit) != v:t_dict
    return v:null
  endif

  let l:last_commit = flog#get_commit_at_line(l:lastline)

  if type(l:last_commit) != v:t_dict
    return v:null
  endif

  return l:should_swap ? [l:last_commit, l:first_commit] : [l:first_commit, l:last_commit]
endfunction

" Commit navigation {{{

function! flog#jump_commits(commits) abort
  let l:state = flog#get_state()

  let l:current_commit = flog#get_commit_at_line()
  if type(l:current_commit) != v:t_dict
    return
  endif

  let l:index = index(l:state.commits, l:current_commit) + a:commits
  let l:index = min([max([l:index, 0]), len(l:state.commits) - 1])

  let l:line = index(l:state.line_commits, l:state.commits[l:index]) + 1

  if l:line >= 0
    exec l:line
  endif
endfunction

function! flog#next_commit() abort
  call flog#jump_commits(v:count1)
endfunction

function! flog#previous_commit() abort
  call flog#jump_commits(-v:count1)
endfunction

" }}}

function! flog#copy_commits(...) range abort
  let l:by_line = get(a:, 1, v:false)
  let l:state = flog#get_state()

  let l:commits = flog#get_commit_selection(a:firstline, a:lastline)

  if type(l:commits) != v:t_list
    return 0
  endif

  let [l:first_commit, l:last_commit] = l:commits

  let l:first_index = index(l:state.commits, l:first_commit)

  if l:by_line
    let l:last_index = index(l:state.commits, l:last_commit)
  else
    let l:last_index = l:first_index + a:lastline - a:firstline
  endif

  let l:commits = l:state.commits[l:first_index : l:last_index]
  let l:commits = map(l:commits, 'v:val.short_commit_hash')

  return setreg(v:register, join(l:commits, ' '))
endfunction

" }}}

" Ref operations {{{

function! flog#get_ref_at_line(...) abort
  let l:line = get(a:, 1, '.')
  if type(l:line) == v:t_string
    let l:line = line(l:line)
  endif
  let l:state = flog#get_state()
  return get(l:state.line_commit_refs, l:line - 1, v:null)
endfunction

function! flog#jump_refs(refs) abort
  let l:state = flog#get_state()

  if l:state.commit_refs == []
    return
  endif

  let l:current_ref = flog#get_ref_at_line()
  let l:current_commit = flog#get_commit_at_line()
  if type(l:current_commit) != v:t_dict
    return
  endif

  let l:refs = a:refs
  if l:refs < 0 && l:current_commit.ref_names_unwrapped ==# ''
    let l:refs += 1
  endif

  if type(l:current_ref) != v:t_list
    let l:index = -1
  else
    let l:index = index(l:state.commit_refs, l:current_ref)
  endif
  let l:index = max([0, l:index + l:refs])
  if l:index >= len(l:state.commit_refs)
    return
  endif

  let l:line = index(l:state.line_commit_refs, l:state.commit_refs[l:index]) + 1

  if l:line >= 0
    exec l:line
  endif
endfunction

function! flog#jump_to_ref(ref) abort
  let l:state = flog#get_state()
  if !has_key(l:state.ref_line_lookup, a:ref)
    return
  endif
  exec l:state.ref_line_lookup[a:ref] + 1
endfunction

function! flog#next_ref() abort
  call flog#jump_refs(v:count1)
endfunction

function! flog#previous_ref() abort
  call flog#jump_refs(-v:count1)
endfunction

" }}}

" Buffer management {{{

" Graph buffer {{{

" Graph buffer population {{{

function! flog#modify_graph_buffer_contents(content) abort
  let l:state = flog#get_state()

  let l:cursor_pos = line('.')

  silent setlocal modifiable
  silent setlocal noreadonly
  1,$ d
  call append(0, a:content)
  $,$ d
  call flog#graph_buffer_settings()

  exec l:cursor_pos
  let l:state.line_commits = []
endfunction

function! flog#set_graph_buffer_commits(commits) abort
  let l:state = flog#get_state()

  call flog#modify_graph_buffer_contents(flog#get_log_display(a:commits))

  let l:state.line_commits = []

  let l:state.commit_refs = []
  let l:state.line_commit_refs = []
  let l:state.ref_line_lookup = {}

  let l:cr = v:null

  let l:scr = l:state.commit_refs
  let l:srl = l:state.ref_line_lookup
  let l:slc = l:state.line_commits
  let l:slr = l:state.line_commit_refs

  for l:c in a:commits
    if l:c.ref_name_list !=# []
      let l:cr = l:c.ref_name_list
      let l:scr += [l:cr]
      for l:r in l:cr
        let l:srl[l:r] = len(l:slc)
      endfor
    endif

    let l:slc += repeat([l:c], len(l:c.display))
    let l:slr += repeat([l:cr], len(l:c.display))
  endfor
endfunction

function! flog#set_graph_buffer_title() abort
  let l:opts = flog#get_resolved_graph_options()

  let l:title = 'flog-' . l:opts.instance
  if l:opts.all && !l:opts.limit
    let l:title .= ' [all]'
  endif
  if l:opts.bisect
    let l:title .= ' [bisect]'
  endif
  if l:opts.no_merges
    let l:title .= ' [no_merges]'
  endif
  if l:opts.reflog
    let l:title .= ' [reflog]'
  endif
  if l:opts.reverse
    let l:title .= ' [reverse]'
  endif
  if l:opts.no_graph
    let l:title .= ' [no_graph]'
  endif
  if l:opts.no_patch
    let l:title .= ' [no_patch]'
  endif
  if l:opts.skip != v:null
    let l:title .= ' [skip=' . l:opts.skip . ']'
  endif
  if l:opts.sort != v:null
    let l:title .= ' [sort=' . l:opts.sort . ']'
  endif
  if l:opts.max_count != v:null
    let l:title .= ' [max_count=' . l:opts.max_count . ']'
  endif
  if l:opts.search != v:null
    let l:title .= ' [search=' . flog#ellipsize(l:opts.search) . ']'
  endif
  if l:opts.patch_search != v:null
    let l:title .= ' [patch_search=' . flog#ellipsize(l:opts.patch_search) . ']'
  endif
  if l:opts.author != v:null
    let l:title .= ' [author=' . l:opts.author . ']'
  endif
  if l:opts.limit != v:null
    let l:title .= ' [limit=' . flog#ellipsize(l:opts.limit) . ']'
  endif
  if len(l:opts.rev) == 1
    let l:title .= ' [rev=' . flog#ellipsize(l:opts.rev[0]) . ']'
  endif
  if len(l:opts.rev) > 1
    let l:title .= ' [rev=...]'
  endif
  if len(l:opts.path) == 1
    let l:title .= ' [path=' . flog#ellipsize(fnamemodify(l:opts.path[0], ':t')) . ']'
  elseif len(l:opts.path) > 1
    let l:title .= ' [path=...]'
  endif

  exec 'silent file '. l:title

  return l:title
endfunction

function! flog#set_graph_buffer_color() abort
  if get(g:, 'flog_use_ansi_esc')
    let l:state = flog#get_state()
    if !l:state.ansi_esc_called
      AnsiEsc
      let l:state.ansi_esc_called = 1
    else
      AnsiEsc!
    endif
  endif
endfunction

function! flog#get_graph_cursor() abort
  let l:state = flog#get_state()
  if l:state.line_commits != []
    return flog#get_commit_at_line()
  endif
  return v:null
endfunction

function! flog#restore_graph_cursor(cursor) abort
  if type(a:cursor) != v:t_dict
    return
  endif

  let l:state = flog#get_state()

  if len(l:state.commits) == 0
    return
  endif

  let l:short_commit_hash = a:cursor.short_commit_hash

  let l:commit = flog#get_commit_at_line()
  if type(l:commit) != v:t_dict
    return
  endif
  if l:short_commit_hash ==# l:commit.short_commit_hash
    return
  endif

  let l:line = v:null
  for l:commit in l:state.commits
    if l:commit.short_commit_hash == l:short_commit_hash
      call cursor(index(l:state.line_commits, l:commit) + 1, 1)
      return
    endif
  endfor
endfunction

function! flog#populate_graph_buffer() abort
  let l:state = flog#get_state()

  let l:cursor = flog#get_graph_cursor()

  let l:build_log_command_fn = get(g:, 'flog_build_log_command_fn', 'flog#build_log_command')
  let l:command = call(l:build_log_command_fn, [])
  let l:state.previous_log_command = l:command

  let l:output = flog#systemlist(l:command)
  let l:commits = flog#parse_log_output(l:output)

  call flog#set_graph_buffer_commits(l:commits)
  call flog#set_graph_buffer_title()
  call flog#set_graph_buffer_color()

  let l:state.commits = l:commits

  call flog#restore_graph_cursor(l:cursor)
endfunction

function! flog#graph_buffer_settings() abort
  exec 'lcd ' . flog#get_fugitive_workdir()
  set filetype=floggraph
endfunction

function! flog#initialize_graph_buffer(state) abort
  call flog#set_buffer_state(a:state)
  call flog#trigger_fugitive_git_detection()
  call flog#graph_buffer_settings()
  call flog#populate_graph_buffer()
endfunction

" }}}

" Graph buffer settings {{{

function! flog#update_options(args, force) abort
  let l:state = flog#get_state()
  let l:defaults = flog#get_internal_default_args()

  if a:force
    call extend(l:state, l:defaults)
  endif

  call flog#parse_set_args(a:args, l:state, l:defaults)

  call flog#populate_graph_buffer()
endfunction

function! flog#toggle_all_refs_option() abort
  let l:state = flog#get_state()
  let l:state.all = l:state.all ? v:false : v:true
  call flog#populate_graph_buffer()
endfunction

function! flog#toggle_bisect_option() abort
  let l:state = flog#get_state()
  let l:state.bisect = l:state.bisect ? v:false : v:true
  call flog#populate_graph_buffer()
endfunction

function! flog#toggle_no_merges_option() abort
  let l:state = flog#get_state()
  let l:state.no_merges = l:state.no_merges ? v:false : v:true
  call flog#populate_graph_buffer()
endfunction

function! flog#toggle_reflog_option() abort
  let l:state = flog#get_state()
  let l:state.reflog = l:state.reflog ? v:false : v:true
  call flog#populate_graph_buffer()
endfunction

function! flog#toggle_reverse_option() abort
  let l:state = flog#get_state()
  let l:state.reverse = l:state.reverse ? v:false : v:true
  call flog#populate_graph_buffer()
endfunction

function! flog#toggle_no_graph_option() abort
  let l:state = flog#get_state()
  let l:state.no_graph = l:state.no_graph ? v:false : v:true
  call flog#populate_graph_buffer()
endfunction

function! flog#toggle_no_patch_option() abort
  let l:state = flog#get_state()
  let l:state.no_patch = l:state.no_patch ? v:false : v:true
  call flog#populate_graph_buffer()
endfunction

function! flog#set_skip_option(skip) abort
  let l:state = flog#get_state()
  let l:state.skip = a:skip
  call flog#populate_graph_buffer()
endfunction

function! flog#change_skip_by_max_count(multiplier) abort
  let l:state = flog#get_state()
  if a:multiplier == 0 || l:state.max_count == v:null
    return
  endif
  if l:state.skip == v:null
    let l:state.skip = 0
  endif
  let l:state.skip = max([0, l:state.skip + l:state.max_count * a:multiplier])
  call flog#populate_graph_buffer()
endfunction

function! flog#set_sort_option(sort) abort
  let l:state = flog#get_state()
  let l:state.sort = a:sort
  call flog#populate_graph_buffer()
endfunction

function! flog#cycle_sort_option() abort
  let l:state = flog#get_state()

  if l:state.sort == v:null
    let l:state.sort = g:flog_sort_types[0].name
  else
    let l:sort_type = flog#get_sort_type(l:state.sort)
    let l:sort_index = index(g:flog_sort_types, l:sort_type)
    if l:sort_index == len(g:flog_sort_types) - 1
      let l:state.sort = g:flog_sort_types[0].name
    else
      let l:state.sort = g:flog_sort_types[l:sort_index + 1].name
    endif
  endif

  call flog#populate_graph_buffer()
endfunction

" }}}

" Graph buffer update hook {{{

function! flog#clear_graph_update_hook() abort
  augroup FlogGraphUpdate
    autocmd! * <buffer>
  augroup END
endfunction

function! flog#do_graph_update_hook(graph_buff_num) abort
  if bufnr() != a:graph_buff_num
    return
  endif

  call flog#clear_graph_update_hook()
  call flog#populate_graph_buffer()
endfunction

function! flog#initialize_graph_update_hook(graph_buff_num) abort
  augroup FlogGraphUpdate

    exec 'autocmd! * <buffer=' . a:graph_buff_num . '>'
    if exists('##SafeState')
      exec 'autocmd SafeState <buffer=' . a:graph_buff_num . '> call flog#do_graph_update_hook(' . a:graph_buff_num . ')'
    elseif has('nvim')
      exec 'autocmd WinEnter <buffer=' . a:graph_buff_num . '> call timer_start(0, {-> flog#do_graph_update_hook(' . a:graph_buff_num . ')})'
    else
      exec 'autocmd WinEnter <buffer=' . a:graph_buff_num . '> call flog#do_graph_update_hook(' . a:graph_buff_num . ')'
    endif
  augroup END
endfunction

" }}}

" }}}

" Temporary buffers {{{

function! flog#tmp_buffer_settings() abort
  call flog#deprecate_autocmd('FlogPreviewSetup', 'FlogTmpWinSetup')
  silent doautocmd User FlogTmpWinSetup
endfunction

function! flog#tmp_command_buffer_settings() abort
  call flog#deprecate_autocmd('FlogCommitPreviewSetup', 'FlogTmpCommandWinSetup')
  silent doautocmd User FlogTmpCommandWinSetup
endfunction

function! flog#initialize_tmp_buffer(state) abort
  let a:state.tmp_window_ids += [win_getid()]
  call flog#set_buffer_state(a:state)
  call flog#tmp_buffer_settings()
endfunction

" }}}

" }}}

" Layout management {{{

" Temporary window layout management {{{

function! flog#close_tmp_win() abort
  let l:state = flog#get_state()
  let l:graph_window_id = win_getid()

  for l:tmp_window_id in l:state.tmp_window_ids
    " temporary buffer is not open
    if win_id2tabwin(l:tmp_window_id) == [0, 0]
      continue
    endif

    " get the previous buffer to switch back to it after closing
    call win_gotoid(l:tmp_window_id)
    close!
  endfor

  let l:state.tmp_window_ids = []

  " go back to the previous window
  call win_gotoid(l:graph_window_id)

  return
endfunction

function! flog#open_tmp_win(command) abort
  let l:graph_window_id = win_getid()

  let l:state = flog#get_state()

  let l:saved_window_ids = flog#get_all_window_ids()
  exec a:command
  silent! let l:tmp_window_ids = flog#exclude(flog#get_all_window_ids(), l:saved_window_ids)
  if l:tmp_window_ids != []
    silent! call win_gotoid(l:graph_window_id)
    silent! call flog#close_tmp_win()
    for l:tmp_window_id in l:tmp_window_ids
      silent! call win_gotoid(l:tmp_window_id)
      silent! call flog#initialize_tmp_buffer(l:state)
    endfor
  endif
endfunction

" }}}

" Graph layout management {{{

function! flog#open_graph(state) abort
  let l:window_name = 'flog-' . a:state.instance . ' [uninitialized]'
  silent exec a:state.open_cmd . ' ' . l:window_name

  let a:state.graph_window_id = win_getid()

  call flog#initialize_graph_buffer(a:state)
endfunction

function! flog#open(args) abort
  if !flog#is_fugitive_buffer()
    throw g:flog_not_a_fugitive_buffer
  endif

  let l:original_file = expand('%:p')

  let l:parsed_args = flog#parse_args(a:args)
  let l:initial_state = flog#get_initial_state(l:parsed_args, l:original_file)

  call flog#open_graph(l:initial_state)
endfunction

function! flog#quit() abort
  let l:flog_tab = tabpagenr()
  let l:tabs = tabpagenr('$')
  call flog#close_tmp_win()
  quit!
  if l:tabs > tabpagenr('$') && l:flog_tab == tabpagenr()
    tabprev
  endif
endfunction

" }}}

" }}}

" Command utilities {{{

" Command formatting {{{

" Command formatting helpers {{{

function! flog#is_remote_ref(ref) abort
  let l:split_ref = split(a:ref, '/')
  if len(l:split_ref) < 2
    return 0
  endif
  return index(flog#get_remotes(), l:split_ref[0]) >= 0
endfunction

function! flog#get_cache_refs(cache, line) abort
  let l:ref_cache = a:cache['refs']

  if !has_key(l:ref_cache, a:line)
    let l:commit = flog#get_commit_at_line(a:line)
    if type(l:commit) != v:t_dict || empty(l:commit.ref_name_list)
      return v:null
    endif
    let l:refs = l:commit.ref_name_list

    let l:original_refs = split(l:commit.ref_names_unwrapped, ' \ze-> \|, \|\zetag: ')

    let l:remote_branches = []
    let l:local_branches = []
    let l:special = []
    let l:tags = []

    let l:i = 0
    while l:i < len(l:refs)
      let l:ref = l:refs[l:i]

      if l:ref =~# 'HEAD$\|^refs/'
        call add(l:special, l:ref)
      elseif l:original_refs[l:i] =~# '^tag: '
        call add(l:tags, l:ref)
      elseif flog#is_remote_ref(l:ref)
        call add(l:remote_branches, l:ref)
      else
        call add(l:local_branches, l:ref)
      endif

      let l:i += 1
    endwhile

    let l:ref_cache[a:line] = {
          \ 'local_branches': l:local_branches,
          \ 'remote_branches': l:remote_branches,
          \ 'tags': l:tags,
          \ 'special': l:special,
          \ }
  endif

  return l:ref_cache[a:line]
endfunction

" }}}

" Command format specifier converters {{{

function! flog#cmd_convert_hash(cache, item, line) abort
  return flog#get(flog#get_commit_at_line(a:line), 'short_commit_hash')
endfunction

function! flog#cmd_convert_branch(cache, item, line) abort
  let l:refs = flog#get_cache_refs(a:cache, a:line)
  let l:local_branches = flog#get(l:refs, 'local_branches', [])
  let l:remote_branches = flog#get(l:refs, 'remote_branches', [])
  return get(l:local_branches, 0, get(l:remote_branches, 0, v:null))
endfunction

function! flog#cmd_convert_local_branch(cache, item, line) abort
  let l:refs = flog#get_cache_refs(a:cache, a:line)
  let l:local_branches = flog#get(l:refs, 'local_branches', [])
  let l:remote_branches = flog#get(l:refs, 'remote_branches', [])

  if empty(l:local_branches)
    if empty(l:remote_branches)
      return v:null
    endif
    return substitute(l:remote_branches[0], '.*/', '', '')
  endif
  return l:local_branches[0]
endfunction

function! flog#cmd_convert_line(cache, item, Convert) abort
  return a:Convert(a:cache, a:item, '.')
endfunction

function! flog#cmd_convert_mark(cache, item, Convert) abort
  return a:Convert(a:cache, a:item, a:item[1:])
endfunction

function! flog#cmd_convert_path(cache, item) abort
  let l:state = flog#get_state()
  if empty(l:state.path)
    return v:null
  endif
  return join(map(l:state.path, 'fnameescape(v:val)'), ' ')
endfunction

function! flog#convert_command_format_item(cache, item) abort
  let l:item_cache = a:cache['items']

  " return any cached data

  if has_key(l:item_cache, a:item)
    return l:item_cache[a:item]
  endif

  " convert the specifier

  let l:converted_item = v:null

  if a:item ==# 'h'
    let l:converted_item = flog#cmd_convert_line(a:cache, a:item, function('flog#cmd_convert_hash'))
  elseif a:item =~# "^h'."
    let l:converted_item = flog#cmd_convert_mark(a:cache, a:item, function('flog#cmd_convert_hash'))
  elseif a:item =~# 'b'
    let l:converted_item = flog#cmd_convert_line(a:cache, a:item, function('flog#cmd_convert_branch'))
  elseif a:item =~# "^b'."
    let l:converted_item = flog#cmd_convert_mark(a:cache, a:item, function('flog#cmd_convert_branch'))
  elseif a:item =~# 'l'
    let l:converted_item = flog#cmd_convert_line(a:cache, a:item, function('flog#cmd_convert_local_branch'))
  elseif a:item =~# "^l'."
    let l:converted_item = flog#cmd_convert_mark(a:cache, a:item, function('flog#cmd_convert_local_branch'))
  elseif a:item =~# 'p'
    let l:converted_item = flog#cmd_convert_path(a:cache, a:item)
  else
    echoerr printf('error converting %s', a:item)
    throw g:flog_unsupported_command_format_item
  endif

  " handle result

  let l:item_cache[a:item] = l:converted_item
  return l:converted_item
endfunction

" }}}

function! flog#format_command(format) abort
  " special token flags
  let l:is_in_item = 0
  let l:is_in_long_item = 0
  let l:is_in_long_item_escape = 0

  " special token data
  let l:long_item = ''

  " memoized data
  let l:cache = {
        \ 'items': {},
        \ 'refs': {}
        \ }

  " return data
  let l:ret = ''

  for l:char in split(a:format, '\zs')
    " parse characters in %()
    if l:is_in_long_item
      if l:char ==# ')'
        " end long specifier
        let l:converted_item = flog#convert_command_format_item(l:cache, l:long_item)
        if type(l:converted_item) != v:t_string
          return v:null
        endif
        let l:ret .= l:converted_item

        let l:is_in_long_item = 0
        let l:long_item = ''
      else
        " build specifier
        let l:long_item .= l:char
      endif
      continue
    endif

    " parse character after %
    if l:is_in_item
      if l:char ==# '('
        " start long specifier
        let l:is_in_long_item = 1
      else
        " parse specifier chacter
        let l:converted_item = flog#convert_command_format_item(l:cache, l:char)
        if type(l:converted_item) != v:t_string
          return v:null
        endif
        let l:ret .= l:converted_item
      endif

      let l:is_in_item = 0
      continue
    endif

    " parse normal character
    if l:char ==# '%'
      let l:is_in_item = 1
    else
      let l:ret .= l:char
    endif
  endfor

  return l:ret
endfunction

" }}}

" Command running {{{

function! flog#handle_command_window_cleanup(keep_focus, graph_window_id) abort
  if !a:keep_focus
    call win_gotoid(a:graph_window_id)
    if has('nvim')
      redraw!
    endif
  endif
endfunction

function! flog#handle_command_update_cleanup(should_update, graph_window_id, graph_buff_num) abort
  if a:should_update
    if win_getid() != a:graph_window_id
      call flog#initialize_graph_update_hook(a:graph_buff_num)
    else
      call flog#populate_graph_buffer()
    endif
  endif
endfunction

function! flog#handle_command_cleanup(keep_focus, should_update, graph_window_id, graph_buff_num) abort
  call flog#handle_command_window_cleanup(a:keep_focus, a:graph_window_id)
  call flog#handle_command_update_cleanup(a:should_update, a:graph_window_id, a:graph_buff_num)
endfunction

function! flog#run_raw_command(command, ...) abort
  let l:keep_focus = get(a:, 1, v:false)
  let l:should_update = get(a:, 2, v:false)
  let l:is_tmp = get(a:, 3, v:false)

  let l:graph_window_id = win_getid()
  let l:graph_buff_num = bufnr('')

  if type(a:command) != v:t_string
    return
  endif

  if l:is_tmp
    call flog#open_tmp_win(a:command)
    silent! call flog#tmp_command_buffer_settings()
    silent! call flog#handle_command_cleanup(
          \ l:keep_focus, l:should_update, l:graph_window_id, l:graph_buff_num)
  else
    exec a:command
    silent! call flog#handle_command_cleanup(
          \ l:keep_focus, l:should_update, l:graph_window_id, l:graph_buff_num)
  endif
endfunction

function! flog#run_command(command, ...) abort
  let l:keep_focus = get(a:, 1, v:false)
  let l:should_update = get(a:, 2, v:false)
  let l:is_tmp = get(a:, 3, v:false)

  let l:command = flog#format_command(a:command)

  call flog#run_raw_command(l:command, l:keep_focus, l:should_update, l:is_tmp)
endfunction

function! flog#run_tmp_command(command, ...) abort
  let l:keep_focus = get(a:, 1, v:false)
  let l:should_update = get(a:, 2, v:false)

  call flog#run_command(a:command, l:keep_focus, l:should_update, v:true)
endfunction

" }}}

" }}}

" Deprecated functions {{{

function! flog#shell_command(...) range abort
  call flog#deprecate_function('flog#shell_command', 'flog#systemlist', '{command}')
endfunction

function! flog#get_commit_data(...) range abort
  call flog#deprecate_function(
        \ 'flog#get_commit_data',
        \ 'flog#get_commit_at_line',
        \ '[line]')
endfunction

function! flog#get_ref_data(...) range abort
  call flog#deprecate_function('flog#get_ref_data', 'flog#get_ref_at_line', '[line]')
endfunction

function! flog#close_preview(...) range abort
  call flog#deprecate_function('flog#close_preview', 'flog#close_tmp_win', '')
endfunction

function! flog#preview(...) range abort
  call flog#deprecate_function('flog#preview', 'flog#run_tmp_command', '{command}, [keep_focus], [should_update]')
endfunction

function! flog#preview_commit(...) range abort
  call flog#deprecate_function(
        \ 'flog#preview_commit',
        \ 'flog#run_tmp_command',
        \ '"MyCommand %h", [keep_focus], [should_update]')
endfunction

function! flog#preview_split_commit(...) range abort
  call flog#deprecate_function(
        \ 'flog#preview_split_commit',
        \ 'flog#run_tmp_command',
        \ '"(mods) Gsplit %h", [keep_focus]')
endfunction

function! flog#git(...) range abort
  call flog#deprecate_function(
        \ 'flog#git',
        \ 'flog#run_command',
        \ '"(mods) Git (cmd)", [keep_focus], [should_update], [is_tmp]')
endfunction

function! flog#format(...) range abort
  call flog#deprecate_function(
        \ 'flog#format',
        \ 'flog#run_command',
        \ '"(format)", ...')
endfunction

function! flog#join(...) range abort
  call flog#deprecate_function('flog#join', 'flog#run_command')
endfunction

function! flog#get_paths(...) range abort
  call flog#deprecate_function(
        \ 'flog#get_paths',
        \ 'flog#run_command',
        \ '"MyCommand %p", ...')
endfunction

function! flog#get_hash_at_line(...) range abort
  call flog#deprecate_function(
        \ 'flog#get_hash_at_line',
        \ 'flog#run_command',
        \ '"MyCommand %h", ...')
endfunction

function! flog#format_commit(...) range abort
  call flog#deprecate_function(
        \ 'flog#format_commit',
        \ 'flog#run_command',
        \ '"MyCommand %h", ...')
endfunction

function! flog#format_commit_selection(...) range abort
  call flog#deprecate_function(
        \ 'flog#format_commit_selection',
        \ 'flog#run_command',
        \ "\"MyCommand %(h'<) %(h'>)\", ...")
endfunction

function! flog#get_branch_at_line(...) range abort
  call flog#deprecate_function(
        \ 'flog#get_branch_at_line',
        \ 'flog#run_command',
        \ '"MyCommand %b", ...')
endfunction

function! flog#get_local_branch_at_line(...) range abort
  call flog#deprecate_function(
        \ 'flog#get_local_branch_at_line',
        \ 'flog#run_command',
        \ '"MyCommand %l", ...')
endfunction

function! flog#get_cache_curr_line_refs(...) range abort
  call flog#deprecate_function(
        \ 'flog#get_cache_curr_line_refs',
        \ 'flog#get_cache_refs',
        \ '(cache), "."')
endfunction

function! flog#cmd_item_hash_at_curr_line(...) range abort
  call flog#deprecate_function(
        \ 'flog#cmd_item_hash_at_curr_line',
        \ 'flog#cmd_item_hash_at_curr_line',
        \ '(cache), (item), "."')
endfunction

function! flog#cmd_item_hash(...) range abort
  call flog#deprecate_function(
        \ 'flog#cmd_item_hash',
        \ 'flog#cmd_convert_hash',
        \ '(cache), (item), (line)')
endfunction

function! flog#cmd_item_branch(...) range abort
  call flog#deprecate_function(
        \ 'flog#cmd_item_branch',
        \ 'flog#cmd_convert_branch',
        \ '(cache), (item), "."')
endfunction

function! flog#cmd_item_local_branch(...) range abort
  call flog#deprecate_function(
        \ 'flog#cmd_item_local_branch',
        \ 'flog#cmd_convert_local_branch',
        \ '(cache), (item), "."')
endfunction

function! flog#cmd_item_path(...) range abort
  call flog#deprecate_function(
        \ 'flog#cmd_item_path',
        \ 'flog#cmd_convert_path',
        \ '(cache), (item)')
endfunction


" }}}

" vim: set et sw=2 ts=2 fdm=marker:
