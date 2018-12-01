" Utilities {{{

function! flog#instance() abort
  let l:instance = g:flog_instance_counter
  let g:flog_instance_counter += 1
  return l:instance
endfunction

" }}}

" Shell interface {{{

function! flog#shell_command(command) abort
  return split(system(a:command), '\n')
endfunction

" }}}

" Fugitive interface {{{

function! flog#is_fugitive_buffer() abort
  try
    call fugitive#buffer()
  catch /not a Fugitive buffer/
    return v:false
  endtry
  return v:true
endfunction

function! flog#get_initial_fugitive_buffer() abort
  return fugitive#buffer()
endfunction

function! flog#get_fugitive_workdir() abort
  let l:tree = flog#get_state().fugitive_buffer.repo().tree()
  return l:tree
endfunction

function! flog#get_fugitive_git_command() abort
  let l:git_command = flog#get_state().fugitive_buffer.repo().git_command()
  return l:git_command
endfunction

function! flog#trigger_fugitive_git_detection() abort
  let b:git_dir = flog#get_state().fugitive_buffer.repo().dir()
  let l:workdir = flog#get_fugitive_workdir()
  call FugitiveDetect(l:workdir)
endfunction

" }}}

" Argument handling {{{

function! flog#parse_arg_opt(arg) abort
  let l:opt = matchstr(a:arg, '=\zs.*')
  return l:opt
endfunction

function! flog#parse_args(args) abort
  " defaults
  let l:additional_args = v:null
  let l:format = '%ai [%h] {%an}%d %s'
  let l:all = v:false
  let l:open_cmd = 'tabedit'
  let l:path = v:null

  for l:arg in a:args
    if l:arg =~# '^format='
      let l:format = flog#parse_arg_opt(l:arg)
    elseif l:arg =~# '^additional_args='
      let l:additional_args = flog#parse_arg_opt(l:arg)
    elseif l:arg ==# 'all'
      let l:all = v:true
    elseif l:arg =~# '^open_cmd='
      let l:open_cmd = flog#parse_arg_opt(l:arg)
    elseif l:arg =~# '^path='
      let l:path = flog#parse_arg_opt(l:arg)
    else
      echoerr 'error parsing argument ' . l:arg
      throw g:flog_unsupported_argument
    endif
  endfor

  return {
        \ 'additional_args': l:additional_args,
        \ 'format': l:format,
        \ 'all': l:all,
        \ 'open_cmd': l:open_cmd,
        \ 'path': l:path
        \ }
endfunction

" }}}

" State management {{{

function! flog#get_initial_state(parsed_args) abort
  return extend(copy(a:parsed_args), {
        \ 'instance': flog#instance(),
        \ 'fugitive_buffer': flog#get_initial_fugitive_buffer(),
        \ 'graph_window_name': v:null,
        \ 'previous_log_command': v:null,
        \ 'preview_file': v:null,
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
  return string(l:format)
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

  let l:flog_commit_end = g:flog_format_end . '\(\n' . g:flog_graph_branch_pattern . '\+\n\)\?\zs'
  let l:raw_commits = split(join(a:output, "\n"), l:flog_commit_end)

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

function! flog#build_log_command() abort
  let l:state = flog#get_state()

  let l:command = flog#get_fugitive_git_command()
  let l:command .= ' log --graph --no-color'
  let l:command .= ' --pretty=' . flog#create_log_format()
  if l:state.all
    let l:command .= ' --all'
  endif
  if l:state.additional_args
    let l:command .= ' ' . l:state.additional_args
  endif
  if l:state.path
    let l:command .= ' ' . l:state.path
  endif

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
  let l:index = min([max([l:index, 0]), len(l:state.commits)])

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

" }}}

" Preview buffer {{{

function! flog#preview_buffer_settings() abort
  silent doautocmd User FlogPreviewSetup
endfunction

function! flog#initialize_preview_buffer(state) abort
  let a:state.preview_file = expand('%:p')
  call flog#set_buffer_state(a:state)
  call flog#preview_buffer_settings()
  wincmd p
endfunction

" }}}

" }}}

" Layout management {{{

" Preview layout management {{{

function! flog#close_preview() abort
  let l:state = flog#get_state()

  " preview buffer is not open
  if l:state.preview_file == v:null
    return
  endif

  let l:preview_buffer = bufnr(l:state.preview_file)
  let l:preview_window = bufwinnr(l:preview_buffer)

  " preview buffer has been closed by user
  if l:preview_window < 0
    return
  endif

  " get the previous buffer to switch back to it after closing
  let l:previous_buffer = bufnr('%')
  exec l:preview_window . 'windo bdelete'
  let l:state.preview_file = v:null

  " go back to the previous window
  if l:previous_buffer != l:preview_buffer && bufnr('%') != l:previous_buffer
    wincmd p
  endif

  return
endfunction

function! flog#open_commit(command) abort
  let l:state = flog#get_state()
  call flog#close_preview()
  exec a:command . ' ' . flog#get_commit_data(line('.')).short_commit_hash
  call flog#initialize_preview_buffer(l:state)
endfunction

" }}}

" Graph layout management {{{

function! flog#open_graph(state) abort
  let l:window_name = 'flog-' . a:state.instance
  exec a:state.open_cmd . ' ' . l:window_name

  let a:state.graph_window_name = l:window_name

  call flog#initialize_graph_buffer(a:state)
endfunction

function! flog#open(args) abort
  if !flog#is_fugitive_buffer()
    throw g:flog_not_a_fugitive_buffer
  endif

  let l:parsed_args = flog#parse_args(a:args)
  let l:initial_state = flog#get_initial_state(l:parsed_args)

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

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
