vim9script

export def Get(git_cmd: string): dict<any>
  flog#floggraph#buf#AssertFlogBuf()
  const state = flog#state#GetBufState()

  # Get paths
  const script_path = flog#lua#GetLibPath('graph_bin.lua')

  # Build command
  var cmd = flog#lua#GetBin()
  cmd ..= ' '
  cmd ..= shellescape(script_path)
  cmd ..= ' '
  # start_token
  cmd ..= shellescape(g:flog_commit_start_token)
  cmd ..= ' '
  # enable_graph
  cmd ..= state.opts.graph ? 'true' : 'false'
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

    # Parse subject
    commit.subject = out[out_index]
    add(final_out, out[out_index])
    add(line_commits, commit)
    out_index += 1

    if len > 1
      # Parse body
      var body = {}
      commit.body = body
      var body_index = 1

      while body_index < len
        body[body_index] = out[out_index]
        add(final_out, out[out_index])
        add(line_commits, commit)

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
        add(line_commits, commit)

        out_index += 1
        suffix_index += 1
      endwhile
    endif

    # Record line position
    commit.line = total_lines + 1

    # Update total lines
    total_lines += len + suffix_len

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
