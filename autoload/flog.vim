let g:flog_instance_counter = 0

" used to delineate format specifiers used to retrieve commit data
let g:flog_format_start = '__FSTART__'
let g:flog_format_separator = '__FSEP__'
let g:flog_format_end = '__FEND__'
" used to delineate which part of the log to display to the user
let g:flog_display_commit_start = '__DSTART__'
let g:flog_display_commit_end = '__DEND__'
" information about specifiers for use with --pretty=format:*
let g:flog_format_specifiers = {
      \ 'short_commit_hash': '%h',
      \ 'author_name': '%an',
      \ 'author_relative_date': '%ar',
      \ 'ref_names_unwrapped': '%D',
      \ 'subject': '%s',
      \ }
" the specifiers to use to retrieve data
let g:flog_log_data_format_specifiers = [
      \ 'ref_names_unwrapped',
      \ 'short_commit_hash',
      \ 'author_name',
      \ 'author_relative_date',
      \ 'subject',
      \ ]

" Errors {{{

let g:flog_missing_state = 'flog: could not find state'
let g:flog_not_a_fugitive_buffer = 'flog: not a fugitive buffer'
let g:flog_no_log_output = 'flog: error parsing commits: no git output'
let g:flog_no_commits = 'flog: error parsing commits: no commits found'
let g:flog_missing_commit_start = 'flog: error parsing commits: could not find start of commit'

" }}}

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

" }}}

" Argument handling {{{

function! flog#parse_args(args) abort
  return {
        \ 'additional_args': join(a:args, ' '),
        \ 'format': '%ai [%h] {%an}%d %s'
        \ }
endfunction

" }}}

" State management {{{

function! flog#get_initial_state(parsed_args) abort
  return {
        \ 'additional_args': a:parsed_args.additional_args,
        \ 'format': a:parsed_args.format,
        \ 'instance': flog#instance(),
        \ 'fugitive_buffer': flog#get_initial_fugitive_buffer(),
        \ 'graph_window_name': v:null,
        \ 'previous_log_command': v:null
        \ }
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
  let l:display_pattern .= g:flog_display_commit_start . '\(.*\)' . g:flog_display_commit_end
  let l:commit.display = split(substitute(a:raw_commit, l:display_pattern, '\1\2', ''), "\n")

  return l:commit
endfunction

function! flog#parse_log_output(output) abort
  if len(a:output) == 0
    throw g:flog_no_log_output
  endif

  let l:raw_commits = split(join(a:output, "\n"), g:flog_format_end)

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
  let l:command = flog#get_fugitive_git_command()
  let l:command .= ' log --graph --no-color'
  let l:command .= ' --pretty=' . flog#create_log_format()
  return l:command . ' ' . flog#get_state().additional_args
endfunction

function! flog#get_log_display(commits) abort
  let l:display_lines = []
  for l:commit in a:commits
    let l:display_lines += l:commit.display
  endfor

  return l:display_lines
endfunction

" }}}

" Buffer management {{{

function! flog#modify_graph_buffer_contents(content) abort
  let l:cursor_pos = line('.')

  silent setlocal modifiable
  silent setlocal noreadonly
  1,$ d
  call append(0, a:content)
  call flog#graph_buffer_settings()

  exec l:cursor_pos
endfunction

function! flog#populate_graph_buffer() abort
  let l:state = flog#get_state()

  let l:command = flog#build_log_command()
  let l:output = flog#shell_command(l:command)
  let l:commits = flog#parse_log_output(l:output)

  call flog#modify_graph_buffer_contents(flog#get_log_display(l:commits))

  let l:state.previous_log_command = l:command
  let l:state.commits = l:commits
endfunction

function! flog#graph_buffer_settings() abort
  exec 'lcd ' . flog#get_fugitive_workdir()
  set filetype=floggraph
endfunction

function! flog#initialize_graph_buffer(state) abort
  call flog#set_buffer_state(a:state)
  call flog#graph_buffer_settings()
  call flog#populate_graph_buffer()
endfunction

" }}}

" Layout management {{{

function! flog#open_graph(state) abort
  let l:window_name = 'flog-' . a:state.instance
  exec 'tabedit ' . l:window_name

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

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
