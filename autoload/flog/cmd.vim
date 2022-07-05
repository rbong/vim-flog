"
" This file contains functions which implement Flog Vim commands.
"
" The "cmd/" folder contains functions for each command.
"

" The implementation of ":Flog".
" The "floggraph/" folder contains functions for dealing with this filetype.
function! flog#cmd#Flog(args) abort
  if !flog#fugitive#IsGitBuf()
    throw g:flog_not_a_fugitive_buffer
  endif

  let state = flog#state#Create()

  let workdir = flog#fugitive#GetWorkdir()
  call flog#state#SetWorkdir(state, workdir)

  let default_opts = flog#state#GetDefaultOpts()
  let opts = flog#cmd#flog#args#Parse(default_opts, workdir, a:args)
  call flog#state#SetOpts(state, opts)

  if g:flog_write_commit_graph && !flog#git#HasCommitGraph()
    call flog#git#WriteCommitGraph()
  endif

  call flog#floggraph#buf#Open(state)
  call flog#floggraph#buf#Update()

  return state
endfunction

" The implementation of ":Flogsetargs".
function! flog#cmd#FlogSetArgs(args, force) abort
  let state = flog#state#GetBufState()

  let workdir = flog#state#GetWorkdir(state)
  let opts = a:force ? flog#state#GetInternalDefaultOpts() : state.opts

  call flog#cmd#flog#args#Parse(opts, workdir, a:args)
  call flog#state#SetOpts(state, opts)

  call flog#floggraph#buf#Update()

  return state
endfunction

" The implementation of ":Floggit".
function! flog#cmd#FlogGit(mods, args, bang) abort
  let l:split_args = split(a:args)
  let l:parsed_args = flog#cmd#flog_git#args#Parse(l:split_args)

  let l:cmd = a:mods

  let l:git_args = l:parsed_args.git_args
  if !empty(l:git_args)
    let l:cmd .= ' '
    let l:cmd .= join(l:git_args)
  endif

  let l:cmd .= ' Git'
  let l:cmd .= a:bang

  let l:subcommand_index = l:parsed_args.subcommand_index
  if l:subcommand_index >= 0
    let l:cmd .= ' '
    let l:cmd .= join(l:split_args[l:subcommand_index :])
  end

  return flog#Exec(
        \ l:cmd, l:parsed_args.focus, l:parsed_args.update, l:parsed_args.tmp)
endfunction
