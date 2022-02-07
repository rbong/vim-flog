vim9script

#
# This file contains functions which implement Flog Vim commands.
#
# The "cmd/" folder contains functions for each command.
#

import autoload 'flog.vim'

import autoload 'flog/fugitive.vim'
import autoload 'flog/git.vim'
import autoload 'flog/state.vim' as flog_state

import autoload 'flog/cmd/flog/args.vim' as flog_cmd_args

import autoload 'flog/floggraph/buf.vim'

# The implementation of ":Flog".
# The "floggraph/" folder contains functions for dealing with this filetype.
export def Flog(args: list<string>): dict<any>
  if !fugitive.IsFugitiveBuf()
    throw g:flog_not_a_fugitive_buffer
  endif

  var state = flog_state.Create()

  const fugitive_repo = fugitive.GetRepo()
  flog_state.SetFugitiveRepo(state, fugitive_repo)
  const workdir = flog_state.GetFugitiveWorkdir(state)

  var default_opts = flog_state.GetDefaultOpts()
  const opts = flog_cmd_args.Parse(default_opts, workdir, args)
  flog_state.SetOpts(state, opts)

  if g:flog_write_commit_graph && !git.HasCommitGraph()
    git.WriteCommitGraph()
  endif

  buf.Open(state)
  buf.Update()

  return state
enddef

# The implementation of ":Flogsetargs".
export def FlogSetArgs(args: list<string>, force: bool): dict<any>
  const state = flog_state.GetBufState()

  const workdir = flog_state.GetFugitiveWorkdir(state)
  var opts = force ? flog_state.GetInternalDefaultOpts() : state.opts

  args.Parse(opts, workdir, args)
  flog_state.SetOpts(state, opts)

  buf.Update()

  return state
enddef

# The implementation of ":Floggit".
export def FlogGit(mods: string, args: string, bang: string): string
  return flog#ExecRaw(mods .. ' Git ' .. args, true, true, !empty(bang))
enddef
