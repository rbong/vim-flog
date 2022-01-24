vim9script

#
# This file contains functions which allow vim to communicate with Lua.
#

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

  if g:flog_check_lua_version
    g:flog_check_lua_version = false

    const out = flog#shell#run(bin .. ' -v')[0]
    if out =~ '\c^lua 5\.1\.'
      echoerr 'flog: warning: for speed improvements, please install LuaJIT 2.1'
    elseif out !~ '\c^luajit 2\.1\.'
      echoerr 'flog: warning: only Lua 5.1 and LuaJIT 2.1 are supported'
    endif
  endif

  return 'luajit'
enddef

def flog#lua#get_lua_script(): string
  return shellescape(g:flog_root_dir .. '/lua/flog.lua')
enddef

def flog#lua#get_graph(git_cmd: string): dict<any>
  flog#floggraph#buf#assert_flog_buf()
  const state = flog#state#get_buf_state()

  # Build command
  var cmd = flog#lua#get_bin()
  cmd ..= ' '
  cmd ..= flog#lua#get_lua_script()
  cmd ..= ' '
  cmd ..= state.opts.graph ? '1 ' : '0 '
  cmd ..= g:flog_commit_start_token
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
