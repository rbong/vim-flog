let g:flog_instance_counter = 0

" Errors {{{

let g:flog_missing_state = 'flog: could not find state'
let g:flog_not_a_fugitive_buffer = 'flog: not a fugitive buffer'

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

" }}}

" Argument handling {{{

function! flog#parse_args(args) abort
  return {
        \ 'additional_args': join(a:args, ' ')
        \ }
endfunction

" }}}

" State management {{{

function! flog#get_initial_state(parsed_args) abort
  return {
        \ 'additional_args': a:parsed_args.additional_args,
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

function! flog#build_log_command() abort
  return 'git log --graph ' . flog#get_state().additional_args
endfunction

" }}}

" Buffer management {{{

function! flog#populate_graph_buffer() abort
  let l:state = flog#get_state()
  let l:command = flog#build_log_command()
  call append(0, flog#shell_command(l:command))
  let l:state.previous_log_command = l:command
endfunction

function! flog#graph_buffer_settings() abort
  exec 'cd ' . flog#get_fugitive_workdir()
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
