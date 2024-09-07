"
" This file contains functions which implement Flog Vim commands.
"
" The "cmd/" folder contains functions for each command.
"

" The implementation of ":Flog".
" The "floggraph/" folder contains functions for dealing with this filetype.
function! flog#cmd#Flog(args) abort
  if !flog#backend#IsGitBuf()
    throw g:flog_not_a_fugitive_buffer
  endif

  let l:state = flog#state#Create()

  let l:workdir = flog#git#GetWorkdir()
  call flog#state#SetWorkdir(l:state, l:workdir)

  let l:default_opts = flog#state#GetDefaultOpts()
  let l:opts = flog#cmd#flog#args#Parse(l:default_opts, l:workdir, a:args)
  call flog#state#SetOpts(l:state, l:opts)

  if g:flog_write_commit_graph && !flog#git#HasCommitGraph()
    call flog#git#WriteCommitGraph()
  endif

  call flog#floggraph#buf#Open(l:state)
  call flog#floggraph#buf#Update()

  return l:state
endfunction

" The implementation of ":Flogsetargs".
function! flog#cmd#FlogSetArgs(args, force) abort
  let l:state = flog#state#GetBufState()

  let l:workdir = flog#state#GetWorkdir(l:state)
  let l:opts = a:force ? flog#state#GetInternalDefaultOpts() : l:state.opts

  call flog#cmd#flog#args#Parse(l:opts, l:workdir, a:args)
  call flog#state#SetOpts(l:state, l:opts)

  call flog#floggraph#buf#Update()

  return l:state
endfunction

" The implementation of ":Floggit".
function! flog#cmd#Floggit(mods, args, bang) abort
  let l:split_args = split(a:args)
  let l:parsed_args = flog#cmd#floggit#args#Parse(l:split_args)
  let l:cmd = flog#cmd#floggit#args#ToGitCommand(a:mods, a:bang, l:parsed_args)

  return flog#Exec(l:cmd, l:parsed_args)
endfunction
