vim9script

#
# This file contains functions which implement Flog Vim commands.
#
# The "cmd/" folder contains functions for each command.
#

# The implementation of ":Flog".
# The "floggraph/" folder contains functions for dealing with this filetype.
export def Flog(args: list<string>): dict<any>
  if !flog#fugitive#IsFugitiveBuf()
    throw g:flog_not_a_fugitive_buffer
  endif

  var state = flog#state#Create()

  const fugitive_repo = flog#fugitive#GetRepo()
  flog#state#SetFugitiveRepo(state, fugitive_repo)
  const workdir = flog#state#GetFugitiveWorkdir(state)

  var default_opts = flog#state#GetDefaultOpts()
  const opts = flog#cmd#flog#args#Parse(default_opts, workdir, args)
  flog#state#SetOpts(state, opts)

  if g:flog_write_commit_graph && !flog#git#HasCommitGraph()
    flog#git#WriteCommitGraph()
  endif

  flog#floggraph#buf#Open(state)
  flog#floggraph#buf#Update()

  return state
enddef

# The implementation of ":Flogsetargs".
export def FlogSetArgs(args: list<string>, force: bool): dict<any>
  const state = flog#state#GetBufState()

  const workdir = flog#state#GetFugitiveWorkdir(state)
  var opts = force ? flog#state#GetInternalDefaultOpts() : state.opts

  flog#cmd#flog#args#Parse(opts, workdir, args)
  flog#state#SetOpts(state, opts)

  flog#floggraph#buf#Update()

  return state
enddef

# The implementation of ":Floggit".
export def FlogGit(mods: string, args: string, bang: string): string
  return flog#ExecRaw(mods .. ' Git ' .. args, true, true, !empty(bang))
enddef
