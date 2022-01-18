vim9script

#
# This file contains functions which implement Flog Vim commands.
#
# The "cmd/" folder contains functions for each command.
#

# The implementation of ":Flog".
# The "floggraph/" folder contains functions for dealing with this filetype.
def flog#cmd#flog(args: list<string>): dict<any>
  if !flog#fugitive#is_fugitive_buf()
    throw g:flog_not_a_fugitive_buffer
  endif

  var state = flog#state#create()

  const fugitive_repo = flog#fugitive#get_repo()
  flog#state#set_fugitive_repo(state, fugitive_repo)
  const workdir = flog#state#get_fugitive_workdir(state)

  var default_opts = flog#state#get_default_opts()
  const opts = flog#cmd#flog#args#parse(default_opts, workdir, args)
  flog#state#set_opts(state, opts)

  if g:flog_should_write_commit_graph && !flog#git#has_commit_graph()
    flog#git#write_commit_graph()
  endif

  flog#floggraph#buf#open(state)
  flog#floggraph#buf#update()

  return state
enddef

# The implementation of ":Flogsetargs".
def flog#cmd#flog_set_args(args: list<string>): dict<any>
  const state = flog#state#get_buf_state()

  const workdir = flog#state#get_fugitive_workdir(state)
  flog#cmd#flog#args#parse(state.opts, workdir, args)
  flog#floggraph#buf#update()

  return state
enddef

# The implementation of ":Floggit".
def flog#cmd#flog_git(mods: string, args: string, bang: string): string
  return flog#exec_raw(mods .. ' Git ' .. args, true, true, !empty(bang))
enddef
