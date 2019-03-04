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

" }}}

" Shell interface {{{

function! flog#shell_command(command) abort
  let l:output = system(a:command)
  if v:shell_error
    echoerr l:output
    throw g:flog_shell_error
  endif
  return split(l:output, '\n')
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

function! flog#get_initial_fugitive_repo() abort
  return fugitive#repo()
endfunction

function! flog#get_fugitive_workdir() abort
  let l:tree = flog#get_state().fugitive_repo.tree()
  return l:tree
endfunction

function! flog#get_fugitive_git_command() abort
  let l:git_command = flog#get_state().fugitive_repo.git_command()
  return l:git_command
endfunction

function! flog#trigger_fugitive_git_detection() abort
  let b:git_dir = flog#get_state().fugitive_repo.dir()
  let l:workdir = flog#get_fugitive_workdir()
  call FugitiveDetect(l:workdir)
endfunction

" }}}

" Argument handling {{{

" Argument parsing {{{

function! flog#parse_arg_opt(arg) abort
  let l:opt = matchstr(a:arg, '=\zs.*')
  return l:opt
endfunction

function! flog#parse_path_opt(arg) abort
  return [fnameescape(fnamemodify(expand(flog#parse_arg_opt(a:arg)), ':p'))]
endfunction

function! flog#parse_args(args) abort
  " defaults
  let l:raw_args = v:null
  let l:format = g:flog_default_format
  let l:date = g:flog_default_date_format
  let l:all = v:false
  let l:bisect = v:false
  let l:open_cmd = 'tabedit'
  let l:rev = v:null
  let l:path = []

  for l:arg in a:args
    if l:arg =~# '^-format='
      let l:format = flog#parse_arg_opt(l:arg)
    elseif l:arg =~# '^-date='
      let l:date = flog#parse_arg_opt(l:arg)
    elseif l:arg =~# '^-raw-args='
      let l:raw_args = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# '-all'
      let l:all = v:true
    elseif l:arg ==# '-bisect'
      let l:bisect = v:true
    elseif l:arg =~# '^-open-cmd='
      let l:open_cmd = flog#parse_arg_opt(l:arg)
    elseif l:arg =~# '^-rev='
      let l:rev = flog#parse_arg_opt(l:arg)
    elseif l:arg =~# '^-path='
      let l:path += flog#parse_path_opt(l:arg)
    else
      echoerr 'error parsing argument ' . l:arg
      throw g:flog_unsupported_argument
    endif
  endfor

  return {
        \ 'raw_args': l:raw_args,
        \ 'format': l:format,
        \ 'date': l:date,
        \ 'all': l:all,
        \ 'bisect': l:bisect,
        \ 'open_cmd': l:open_cmd,
        \ 'rev': l:rev,
        \ 'path': l:path,
        \ }
endfunction

" }}}

" Argument completion {{{

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

function! flog#complete_line(arg_lead, cmd_line, cursor_pos) abort
  let l:line = line('.')
  let l:firstline = line("'<")
  let l:lastline = line("'>")

  if (l:line != l:firstline && l:line != l:lastline) || l:firstline == l:lastline
    " complete for only the current line
    let l:commit = flog#get_commit_data(line('.'))
    let l:completions = [l:commit.short_commit_hash] + l:commit.ref_name_list
  else
    " complete for a range
    let l:first_commit = flog#get_commit_data(l:firstline)
    let l:last_commit = flog#get_commit_data(l:lastline)
    let l:completions = [l:first_commit.short_commit_hash, l:last_commit.short_commit_hash]
          \ + l:first_commit.ref_name_list + l:last_commit.ref_name_list
          \ + [l:last_commit.short_commit_hash . '..' . l:first_commit.short_commit_hash]
  endif

  return "\n" . join(l:completions, "\n")
endfunction

function! flog#complete_git(arg_lead, cmd_line, cursor_pos) abort
  if len(split(a:cmd_line, ' ', v:true)) <= 2
    return "\n" . join(g:flog_git_commands, "\n")
  endif
  let l:completions = flog#complete_line(a:arg_lead, a:cmd_line, a:cursor_pos)
  let l:completions .= "\n" . join(getcompletion(a:arg_lead, 'file'), "\n")
  return l:completions
endfunction

function! flog#complete_format(arg_lead) abort
  " build patterns
  let l:completable_pattern = g:flog_eat_specifier_pattern
        \ . '\zs%' . g:flog_completable_specifier_pattern . '\?$'
  let l:noncompletable_pattern = g:flog_eat_specifier_pattern
        \ . '\zs%' . g:flog_noncompletable_specifier_pattern . '$'

  " test the arg lead
  if a:arg_lead =~# l:noncompletable_pattern
    " format ends with an incompletable pattern
    return ''
  elseif a:arg_lead =~# l:completable_pattern
    " format ends with a completable pattern
    let l:lead = substitute(a:arg_lead, l:completable_pattern, '', '')
    let l:completions = map(copy(g:flog_completion_specifiers), 'l:lead . v:val')
    return "\n" . join(l:completions, "\n")
  else
    " format does not end with any special atom
    return a:arg_lead . '%'
  endif
endfunction

function! flog#complete_date(arg_lead) abort
  let [l:lead, l:path] = flog#split_single_completable_arg(a:arg_lead)
  let l:completions = map(copy(g:flog_date_formats), 'l:lead . v:val')
  return "\n" . join(l:completions, "\n")
endfunction

function! flog#complete_open_cmd(arg_lead) abort
  " get the lead without the last command
  let [l:lead, l:last] = flog#split_completable_arg(a:arg_lead)

  " build the list of possible completions
  let l:completions = []
  let l:completions += map(copy(g:flog_open_cmd_modifiers), 'l:lead . v:val')
  let l:completions += map(copy(g:flog_open_cmds), 'l:lead . v:val')

  return "\n" . join(l:completions, "\n")
endfunction

function! flog#complete_rev(arg_lead) abort
  if !flog#is_fugitive_buffer()
    return ''
  endif
  let [l:lead, l:last] = flog#split_single_completable_arg(a:arg_lead)
  let l:cmd = fugitive#repo().git_command()
        \ . ' rev-parse --symbolic --branches --tags --remotes'
  let l:revs = flog#shell_command(l:cmd) +  ['HEAD', 'FETCH_HEAD', 'MERGE_HEAD', 'ORIG_HEAD']
  return "\n" . join(map(l:revs, 'l:lead . v:val'), "\n")
endfunction

function! flog#complete_path(arg_lead) abort
  let [l:lead, l:path] = flog#split_single_completable_arg(a:arg_lead)

  " remove trailing backslashes to prevent evaluation errors
  let l:path = substitute(l:path, '\\*$', '', '')
  try
    " unescape spaces to deal with argument interpolation
    let l:path = substitute(l:path, '\\ ', ' ', '')
  catch /E114:/
    " invalid trailing escape sequence
    return ''
  endtry
  let l:files = getcompletion(l:path, 'file')

  " build the completion and re-apply escape sequences
  let l:completions = map(l:files, "l:lead . substitute(v:val, ' ', '\\\\ ', '')")

  return "\n" . join(l:completions, "\n")
endfunction

function! flog#complete(arg_lead, cmd_line, cursor_pos) abort
  if a:arg_lead ==# ''
    return g:flog_default_completion
  elseif a:arg_lead =~# '^-format='
    return flog#complete_format(a:arg_lead)
  elseif a:arg_lead =~# '^-date='
    return flog#complete_date(a:arg_lead)
  elseif a:arg_lead =~# '^-open-cmd='
    return flog#complete_open_cmd(a:arg_lead)
  elseif a:arg_lead =~# '^-rev='
    return flog#complete_rev(a:arg_lead)
  elseif a:arg_lead =~# '^-path='
    return flog#complete_path(a:arg_lead)
  endif
  return g:flog_default_completion
endfunction

" }}}

" }}}

" State management {{{

function! flog#get_initial_state(parsed_args, original_file) abort
  return extend(copy(a:parsed_args), {
        \ 'instance': flog#instance(),
        \ 'fugitive_repo': flog#get_initial_fugitive_repo(),
        \ 'original_file': a:original_file,
        \ 'graph_window_id': v:null,
        \ 'preview_window_ids': [],
        \ 'previous_log_command': v:null,
        \ 'line_commits': [],
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

function! flog#parse_log_commit(raw_commit) abort
  " trim past the start of the format
  let l:trimmed_commit = substitute(a:raw_commit, '.*' . g:flog_format_start, '', '')

  if l:trimmed_commit ==# a:raw_commit
    echoerr 'error parsing commit ' . a:raw_commit
    throw g:flog_missing_commit_start
  endif

  " separate the commit string
  let l:split_commit = split(l:trimmed_commit, g:flog_format_separator, 1)

  let l:commit = {}

  " capture each data specifier and store it
  for l:i in range(len(g:flog_log_data_format_specifiers))
    let l:specifier = g:flog_log_data_format_specifiers[l:i]
    let l:data = l:split_commit[l:i]
    let l:commit[l:specifier] = l:data
  endfor

  let l:commit.ref_name_list = split(l:commit.ref_names_unwrapped, ' -> \|, \|tag: ')

  " capture display information
  let l:display_pattern = '^\(.*\)' . g:flog_format_start . '.*' 
  let l:display_pattern .= g:flog_display_commit_start . '\(.*\)' . g:flog_display_commit_end . '.*'
  let l:display_pattern .= g:flog_format_end . '\(.*\)'
  let l:display = substitute(a:raw_commit, l:display_pattern, '\1\2\3', '')
  let l:commit.display = split(l:display, "\n")

  return l:commit
endfunction

function! flog#parse_log_output(output) abort
  if len(a:output) == 0
    throw g:flog_no_log_output
  endif

  let l:commit_split_pattern =
        \ '\(\n\|^\)\zs\ze\(.\(\n\|' . g:flog_format_start . '\)\@<!\)\{-}'
        \ . g:flog_format_start
  let l:raw_commits = split(join(a:output, "\n"), l:commit_split_pattern)

  let g:c = l:raw_commits

  let g:raw_commits = l:raw_commits

  if len(l:raw_commits) == 0
    throw g:flog_no_commits
  endif

  let l:commits = []
  for l:raw_commit in l:raw_commits
    let l:commits += [flog#parse_log_commit(l:raw_commit)]
  endfor
  return l:commits
endfunction

function! flog#build_log_paths() abort
  let l:state = flog#get_state()
  if len(l:state.path) == 0
    return ''
  endif
  let l:paths = map(l:state.path, 'fnamemodify(v:val, ":.")')
  return ' -- ' . join(l:paths, ' ')
endfunction

function! flog#build_log_command() abort
  let l:state = flog#get_state()

  let l:command = flog#get_fugitive_git_command()
  let l:command .= ' log --graph --no-color'
  let l:command .= ' --pretty=' . flog#create_log_format()
  let l:command .= ' --date=' . shellescape(l:state.date)
  if l:state.all
    let l:command .= ' --all'
  endif
  if l:state.bisect
    let l:command .= ' --bisect'
  endif
  if l:state.raw_args != v:null
    let l:command .= ' ' . l:state.raw_args
  endif
  if l:state.rev != v:null
    let l:command .= ' ' . l:state.rev
  endif
  let l:command .= flog#build_log_paths()

  return l:command
endfunction

function! flog#get_log_display(commits) abort
  let l:display_lines = []
  for l:commit in a:commits
    let l:display_lines += l:commit.display
  endfor

  return l:display_lines
endfunction

" }}}

" Commit operations {{{

function! flog#get_commit_data(line) abort
  let l:state = flog#get_state()
  return l:state.line_commits[a:line - 1]
endfunction

function! flog#jump_commits(commits) abort
  let l:state = flog#get_state()

  let l:current_commit = flog#get_commit_data(line('.'))

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

" Buffer management {{{

" Graph buffer {{{

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
  for l:commit in a:commits
    for l:i in range(len(l:commit.display))
      let l:state.line_commits += [l:commit]
    endfor
  endfor
endfunction

function! flog#populate_graph_buffer() abort
  let l:state = flog#get_state()

  let l:command = flog#build_log_command()
  let l:output = flog#shell_command(l:command)
  let l:commits = flog#parse_log_output(l:output)

  call flog#set_graph_buffer_commits(l:commits)

  let l:state.previous_log_command = l:command
  let l:state.commits = l:commits
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

" }}}

" Preview buffer {{{

function! flog#preview_buffer_settings() abort
  silent doautocmd User FlogPreviewSetup
endfunction

function! flog#commit_preview_buffer_settings() abort
  silent doautocmd User FlogCommitPreviewSetup
endfunction

function! flog#initialize_preview_buffer(state) abort
  let a:state.preview_window_ids += [win_getid()]
  call flog#set_buffer_state(a:state)
  call flog#preview_buffer_settings()
endfunction

" }}}

" }}}

" Layout management {{{

" Preview layout management {{{

function! flog#close_preview() abort
  let l:state = flog#get_state()
  let l:previous_window_id = win_getid()

  for l:preview_window_id in l:state.preview_window_ids
    " preview buffer is not open
    if win_id2tabwin(l:preview_window_id) == [0, 0]
      continue
    endif

    " get the previous buffer to switch back to it after closing
    call win_gotoid(l:preview_window_id)
    close
  endfor

  let l:state.preview_window_ids = []

  " go back to the previous window
  call win_gotoid(l:previous_window_id)

  return
endfunction

function! flog#preview(command, ...) abort
  let l:keep_focus = exists('a:0') ? a:0 : v:false
  let l:previous_window_id = win_getid()
  let l:state = flog#get_state()

  call flog#close_preview()
  let l:saved_window_ids = flog#get_all_window_ids()
  exec a:command
  let l:preview_window_ids = flog#exclude(flog#get_all_window_ids(), l:saved_window_ids)
  for l:preview_window_id in l:preview_window_ids
    call win_gotoid(l:preview_window_id)
    call flog#initialize_preview_buffer(l:state)
  endfor

  if !l:keep_focus
    call win_gotoid(l:previous_window_id)
  endif
endfunction

function! flog#preview_commit(open_cmd, ...) abort
  let l:keep_focus = exists('a:0') ? a:0 : v:false
  let l:previous_window_id = win_getid()

  let l:hash = flog#get_commit_data(line('.')).short_commit_hash
  call flog#preview(a:open_cmd . ' ' . l:hash, v:true)
  call flog#commit_preview_buffer_settings()

  if !l:keep_focus
    call win_gotoid(l:previous_window_id)
  endif
endfunction

" }}}

" Graph layout management {{{

function! flog#open_graph(state) abort
  let l:window_name = 'flog-' . a:state.instance
  exec a:state.open_cmd . ' ' . l:window_name

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
  call flog#close_preview()
  quit
  if l:tabs > tabpagenr('$') && l:flog_tab == tabpagenr()
    tabprev
  endif
endfunction

" }}}

" }}}

" User commands {{{

function! flog#git(mods, bang, cmd) abort
  if a:bang ==# '!'
    call flog#preview(a:mods . ' split | Git! ' . a:cmd)
  else
    exec a:mods . ' Git' . ' ' a:cmd
  endif
  call flog#populate_graph_buffer()
endfunction

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
