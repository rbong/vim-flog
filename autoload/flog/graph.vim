vim9script

#
# This file contains functions for generating the commit graph.
#

export def GetUsingInternalLua(git_cmd: string): dict<any>
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
  cmd ..= 'true, '
  cmd ..= 'true, '
  cmd ..= 'vim.eval("g:flog_commit_start_token"), '
  cmd ..= 'vim.eval("g:flog_tmp_enable_graph"), '
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

export def GetUsingBinLua(git_cmd: string): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  # Get paths
  const script_path = flog#lua#GetLibPath('graph_bin.lua')

  # Build command
  var cmd = flog#lua#GetBin()
  cmd ..= ' '
  cmd ..= shellescape(script_path)
  cmd ..= ' '
  cmd ..= shellescape(g:flog_commit_start_token)
  cmd ..= ' '
  cmd ..= state.opts.graph ? 'true' : 'false'
  cmd ..= ' '
  cmd ..= shellescape(git_cmd)

  # Run command
  const out = flog#shell#Run(cmd)

  # Parse number of commits
  const ncommits = str2nr(out[0])

  # Init data
  var out_index = 1
  var commits = []
  var commit_index = 0
  var commits_by_hash = {}
  var line_commits = []
  var final_out = []
  var total_lines = 0

  # Parse output
  while commit_index < ncommits
    # Init commit
    var commit = {}

    # Parse hash
    const hash = out[out_index]
    commit.hash = hash
    out_index += 1

    # Parse parents
    const last_parent_index = out_index + str2nr(out[out_index])
    var parents = []
    while out_index < last_parent_index
      out_index += 1
      add(parents, out[out_index])
    endwhile
    commit.parents = parents
    out_index += 1

    # Parse refs
    commit.refs = out[out_index]
    out_index += 1

    # Parse commit column
    commit.col = str2nr(out[out_index])
    out_index += 1

    # Parse commit visual column
    commit.format_col = str2nr(out[out_index])
    out_index += 1

    # Parse output
    const ncommit_lines = str2nr(out[out_index])
    const last_out_index = out_index + ncommit_lines
    while out_index < last_out_index
      out_index += 1
      add(final_out, out[out_index])
      add(line_commits, commit)
    endwhile
    out_index += 1
    commit.line = total_lines + 1
    total_lines += ncommit_lines

    # Increment
    add(commits, commit)
    commits_by_hash[hash] = commit
    commit_index += 1
  endwhile

  return {
    output: final_out,
    commits: commits,
    commits_by_hash: commits_by_hash,
    line_commits: line_commits,
    }
enddef

export def Get(git_cmd: string): dict<any>
  flog#floggraph#buf#AssertFlogBuf()

  const lua_path_info = flog#lua#SetLuaPath()
  var graph: dict<any>

  try
    if flog#lua#ShouldUseInternal()
      graph =  GetUsingInternalLua(git_cmd)
    else
      graph = GetUsingBinLua(git_cmd)
    endif
  finally
    flog#lua#ResetLuaPath(lua_path_info)
  endtry

  return graph
enddef
