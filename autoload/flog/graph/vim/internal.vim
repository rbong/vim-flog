vim9script

#
# This file contains functions for generating the commit graph in Vim using
# the internal version of Lua.
#

export def Get(git_cmd: string): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  # Check version
  flog#lua#CheckInternalVersion()

  # Load graph lib
  const graph_lib = flog#lua#GetLibPath('graph.lua')
  exec 'luafile ' .. fnameescape(graph_lib)

  # Set temporary vars
  g:flog_tmp_enable_graph = state.opts.graph
  g:flog_tmp_git_cmd = git_cmd

  # Build command
  var cmd = 'flog_get_graph('
  # enable_vim
  cmd ..= 'true, '
  # enable_nvim
  cmd ..= 'false, '
  # enable_porcelain
  cmd ..= 'true, '
  # start_token
  cmd ..= 'vim.eval("g:flog_commit_start_token"), '
  # enable_graph
  cmd ..= 'vim.eval("g:flog_tmp_enable_graph"), '
  # cmd
  cmd ..= 'vim.eval("g:flog_tmp_git_cmd"))'

  # Evaluate command
  var result = luaeval(cmd)

  # Cleanup
  unlet! g:flog_tmp_enable_graph
  unlet! g:flog_tmp_git_cmd

  return {
    output: result.output,
    commits: result.commits,
    commits_by_hash: result.commits_by_hash,
    line_commits: result.line_commits,
    }
enddef
