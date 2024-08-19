if has('nvim')
  finish
endif

vim9script

#
# This file contains functions for generating the commit graph in Vim.
# This is expensive, so vim9script is used.
# This is not an autoload file because of import bugs with early vim9script.
#

def g:FlogGetVimBinGraph(git_cmd: string): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  const default_collapsed = state.opts.default_collapsed
  const collapsed_commits = state.collapsed_commits

  # Get paths
  const script_path = flog#lua#GetLibPath('graph_bin.lua')

  # Build command
  var cmd = flog#lua#GetBin()
  cmd ..= ' '
  cmd ..= shellescape(script_path)
  cmd ..= ' '
  # instance_number
  cmd ..= state.instance_number
  cmd ..= ' '
  # start_token
  cmd ..= shellescape(g:flog_commit_start_token)
  cmd ..= ' '
  # enable_extended_chars
  cmd ..= g:flog_enable_extended_chars ? 'true' : 'false'
  cmd ..= ' '
  # enable_extra_padding
  cmd ..= g:flog_enable_extra_padding ? 'true' : 'false'
  cmd ..= ' '
  # enable_graph
  cmd ..= state.opts.graph ? 'true' : 'false'
  cmd ..= ' '
  # default_collapsed
  cmd ..= default_collapsed ? 'true' : 'false'
  cmd ..= ' '
  # cmd
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

    # Record line position
    commit.line = total_lines + 1

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

    # Parse commit length
    const len = str2nr(out[out_index])
    commit.len = len
    out_index += 1

    # Parse commit suffix length
    const suffix_len = str2nr(out[out_index])
    commit.suffix_len = suffix_len
    out_index += 1

    if len > 1
      # Parse collapsed body
      commit.collapsed_body = out[out_index]
      out_index += 1
    endif

    # Parse subject
    commit.subject = out[out_index]
    add(final_out, out[out_index])
    add(line_commits, commit_index)
    out_index += 1
    total_lines += 1

    if len > 1
      var collapsed = default_collapsed
      if has_key(collapsed_commits, hash)
        collapsed = collapsed_commits[hash]
      endif

      # Add collapsed body to output

      if collapsed
        add(final_out, commit.collapsed_body)
        add(line_commits, commit_index)
        total_lines += 1
      else
        total_lines += len
      endif

      # Parse body

      var body = {}
      commit.body = body
      var body_index = 1

      while body_index < len
        body[body_index] = out[out_index]

        if !collapsed
          add(final_out, out[out_index])
          add(line_commits, commit_index)
        endif

        out_index += 1
        body_index += 1
      endwhile
    endif

    # Parse suffix
    if suffix_len > 0
      var suffix = {}
      commit.suffix = suffix
      var suffix_index = 1

      while suffix_index <= suffix_len
        suffix[suffix_index] = out[out_index]
        add(final_out, out[out_index])
        add(line_commits, commit_index)

        out_index += 1
        suffix_index += 1
      endwhile

      total_lines += suffix_len
    endif

    # Increment
    add(commits, commit)
    commits_by_hash[hash] = commit_index
    commit_index += 1
  endwhile

  return {
    output: final_out,
    commits: commits,
    commits_by_hash: commits_by_hash,
    line_commits: line_commits,
    }
enddef

def g:FlogUpdateVimBinGraph(graph: dict<any>): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  const default_collapsed = state.opts.default_collapsed
  const collapsed_commits = state.collapsed_commits

  # Init data
  var commits = graph.commits
  var commit_index = 0
  var commits_by_hash = graph.commits_by_hash
  var line_commits = []
  var output = []
  var total_lines = 0

  # Find number of commits
  const ncommits = len(commits)

  # Rebuild output/line commits
  while commit_index < ncommits
    var commit = commits[commit_index]
    var hash = commit.hash
    var len = commit.len
    var suffix_len = commit.suffix_len

    # Update line position
    commit.line = total_lines + 1

    # Add subject
    add(output, commit.subject)
    add(line_commits, commit_index)
    total_lines += 1

    if len > 1
      var collapsed = default_collapsed
      if has_key(collapsed_commits, hash)
        collapsed = collapsed_commits[hash]
      endif

      if collapsed
        # Add collapsed body
        add(output, commit.collapsed_body)
        add(line_commits, commit_index)
        total_lines += 1
      else
        # Add body
        var body_index = 1
        var body = commit.body
        while body_index < len
          add(output, body[body_index])
          add(line_commits, commit_index)
          body_index += 1
        endwhile
        total_lines += len - 1
      endif
    endif

    if suffix_len > 0
      # Add suffix
      var suffix_index = 1
      var suffix = commit.suffix
      while suffix_index <= suffix_len
        add(output, suffix[suffix_index])
        add(line_commits, commit_index)
        suffix_index += 1
      endwhile
      total_lines += suffix_len
    endif

    # Increment
    commit_index += 1
  endwhile

  return {
    output: output,
    commits: commits,
    commits_by_hash: commits_by_hash,
    line_commits: line_commits,
    }
enddef

def g:FlogGetVimInternalGraph(git_cmd: string): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  # Check version
  flog#lua#CheckInternalVersion()

  # Load graph lib
  const graph_lib = flog#lua#GetLibPath('graph.lua')
  exec 'luafile ' .. fnameescape(graph_lib)

  # Set temporary vars
  g:flog_tmp_instance_number = state.instance_number
  g:flog_tmp_enable_graph = state.opts.graph
  g:flog_tmp_default_collapsed = state.opts.default_collapsed
  g:flog_tmp_git_cmd = git_cmd
  g:flog_tmp_collapsed_commits = state.collapsed_commits

  # Build command
  var cmd = 'flog_get_graph('
  # instance_number
  cmd ..= 'vim.eval("g:flog_tmp_instance_number"), '
  # is_vim
  cmd ..= 'true, '
  # is_nvim
  cmd ..= 'false, '
  # enable_porcelain
  cmd ..= 'true, '
  # start_token
  cmd ..= 'vim.eval("g:flog_commit_start_token"), '
  # enable_extended_chars
  cmd ..= 'vim.eval("g:flog_enable_extended_chars"), '
  # enable_extra_padding
  cmd ..= 'vim.eval("g:flog_enable_extra_padding"), '
  # enable_graph
  cmd ..= 'vim.eval("g:flog_tmp_enable_graph"), '
  # default_collapsed
  cmd ..= 'vim.eval("g:flog_tmp_default_collapsed"), '
  # cmd
  cmd ..= 'vim.eval("g:flog_tmp_git_cmd"), '
  # collapsed_commits
  cmd ..= 'vim.eval("g:flog_tmp_collapsed_commits"))'

  # Evaluate command
  var result = luaeval(cmd)

  # Cleanup
  unlet! g:flog_tmp_instance_number
  unlet! g:flog_tmp_enable_graph
  unlet! g:flog_tmp_git_cmd
  unlet! g:flog_tmp_collapsed_commits

  return {
    output: result.output,
    commits: result.commits,
    commits_by_hash: result.commits_by_hash,
    line_commits: result.line_commits,
    }
enddef

def g:FlogUpdateVimInternalGraph(graph: dict<any>): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  # Check version
  flog#lua#CheckInternalVersion()

  # Load graph lib
  const graph_lib = flog#lua#GetLibPath('graph.lua')
  exec 'luafile ' .. fnameescape(graph_lib)

  # Set temporary vars
  g:flog_tmp_instance_number = state.instance_number
  g:flog_tmp_default_collapsed = state.opts.default_collapsed
  g:flog_tmp_graph = graph
  g:flog_tmp_collapsed_commits = state.collapsed_commits

  # Build command
  var cmd = 'flog_update_graph('
  # instance_number
  cmd ..= 'vim.eval("g:flog_tmp_instance_number"), '
  # is_nvim
  cmd ..= 'false, '
  # default_collapsed
  cmd ..= 'vim.eval("g:flog_tmp_default_collapsed"), '
  # graph
  cmd ..= 'vim.eval("g:flog_tmp_graph"), '
  # collapsed_commits
  cmd ..= 'vim.eval("g:flog_tmp_collapsed_commits"))'

  # Evaluate command
  var result = luaeval(cmd)

  # Cleanup
  unlet! g:flog_tmp_graph
  unlet! g:flog_tmp_collapsed_commits

  return {
    output: result.output,
    commits: result.commits,
    commits_by_hash: result.commits_by_hash,
    line_commits: result.line_commits,
    }
enddef
