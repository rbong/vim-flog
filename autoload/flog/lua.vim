vim9script

#
# This file contains functions which allow Flog to communicate with Lua.
#

def flog#lua#should_use_internal(): bool
  const use_lua = get(g:, 'flog_use_internal_lua', false)

  if use_lua && !has('lua')
    echoerr 'flog: warning: internal Lua is enabled but unavailable'
    return false
  endif

  return use_lua
enddef

g:flog_did_check_lua_internal_version = false

def flog#lua#check_internal_version(): bool
  if g:flog_check_lua_version && !g:flog_did_check_lua_internal_version
    g:flog_did_check_lua_internal_version = true

    if luaeval('_VERSION') !~ '\c^lua 5\.1\(\.\|$\)'
      echoerr 'flog: warning: only Lua 5.1 and LuaJIT 2.1 are supported'
    elseif empty(luaeval('jit and jit.version'))
      echoerr 'flog: warning: for speed improvements, please compile Vim with LuaJIT 2.1'
    endif

    return true
  endif

  return false
enddef

g:flog_did_check_lua_bin_version = false

def flog#lua#check_bin_version(bin: string): bool
  if g:flog_check_lua_version && !g:flog_did_check_lua_bin_version
    g:flog_did_check_lua_bin_version = true

    const out = flog#shell#run(bin .. ' -v')[0]

    if out =~ '\c^lua 5\.1\(\.\|$\)'
      echoerr 'flog: warning: for speed improvements, please install LuaJIT 2.1'
    elseif out !~ '\c^luajit 2\.1\(\.\|$\)'
      echoerr 'flog: warning: only Lua 5.1 and LuaJIT 2.1 are supported'
    endif

    return true
  endif

  return false
enddef

def flog#lua#get_bin(): string
  var bin = ''

  if exists('g:flog_lua_bin')
    bin = shellescape(g:flog_lua_bin)
  elseif !executable('luajit')
    echoerr 'flog: please install LuaJIT 2.1 it or set it with g:flog_lua_bin'
    throw g:flog_lua_not_found
  else
    bin = 'luajit'
  endif

  flog#lua#check_bin_version(bin)

  return bin
enddef

def flog#lua#get_lib_path(lib: string): string
  return g:flog_root_dir .. '/lua/flog/' .. lib
enddef

def flog#lua#get_graph_internal(git_cmd: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  # Check version
  flog#lua#check_internal_version()

  # Load graph lib
  const graph_lib = flog#lua#get_lib_path('graph.lua')
  exec 'luafile ' .. fnameescape(graph_lib)

  # Set temporary vars
  g:flog_tmp_enable_graph = state.opts.graph
  g:flog_tmp_git_cmd = git_cmd

  # Build command
  var cmd = 'flog_get_graph('
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

def flog#lua#get_graph_bin(git_cmd: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  # Get paths
  const script_path = flog#lua#get_lib_path('graph_bin.lua')
  const graph_lib_path = flog#lua#get_lib_path('graph.lua')

  # Build command
  var cmd = flog#lua#get_bin()
  cmd ..= ' '
  cmd ..= shellescape(script_path)
  cmd ..= ' '
  cmd ..= shellescape(graph_lib_path)
  cmd ..= ' '
  cmd ..= shellescape(g:flog_commit_start_token)
  cmd ..= ' '
  cmd ..= state.opts.graph ? 'true' : 'false'
  cmd ..= ' '
  cmd ..= shellescape(git_cmd)

  # Run command
  const out = flog#shell#run(cmd)

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

def flog#lua#get_graph(git_cmd: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()

  if flog#lua#should_use_internal()
    return flog#lua#get_graph_internal(git_cmd)
  endif

  return flog#lua#get_graph_bin(git_cmd)
enddef
