vim9script

#
# This file contains functions for generating git commit graphs.
#

def flog#graph#create(): dict<any>
  return {
    output: [],
    line_commits: [],
    commit_lines: {},
    commit_cols: {},
    }
enddef

# Generate the commit graph
# This function is optimized for speed, not clarity or length
def flog#graph#generate(commits: list<dict<any>>, all_commit_content: list<list<string>>): dict<any>
  var graph = flog#graph#create()
  var output = graph.output
  var line_commits = graph.line_commits
  var commit_lines = graph.commit_lines
  var commit_cols = graph.commit_cols

  var nlines = 0

  var commit_index = 0
  const ncommits = len(commits)

  # Init graph data
  # Branch hashes by branch index
  var branch_hashes = {}
  # Branch indexes by branch hash
  var branch_indexes = {}
  # Visual number of branch spaces
  var nbranches = 0

  while commit_index < ncommits
    # Get commit data

    const commit = commits[commit_index]
    const commit_content = all_commit_content[commit_index]
    const ncommit_lines = len(commit_content)
    const commit_hash = commit.hash
    var commit_branch_index = get(branch_indexes, commit_hash, -1)
    const ncommit_branches = commit_branch_index < 0 ? nbranches + 1 : nbranches

    const parents = commit.parents
    const nparents = len(commit.parents)
    var moved_parent_branch_index = -1

    var parent_hash_lookup = {}
    for parent in parents
      parent_hash_lookup[parent] = true
    endfor

    # Init visual strings

    # The prefix that goes before the first commit line
    var commit_prefix = ''
    # The prefix that goes after multiline commits
    var commit_multiline_prefix = ''
    # The merge line that goes after the commit
    var merge_line = ''
    # The complex merge line that goes after the merge
    # A complex merge involves both jumping over and merging a branch
    var complex_merge_line = ''

    # Init graph data

    # Number of added or moved parents
    var nplaced_parents = 0
    # Number of merges to the left
    var nmerges_left = 0
    # Number of merges remaining to the right
    var nmerges_right = nparents + 1
    # Init graph data
    # The number of complex merges
    var ncomplex_merges = 0
    # The number of commit columns
    var ncommit_cols = 0

    # Init indexes

    var branch_index = 0
    var parent_index = 0

    # Find first empty parent
    while parent_index < nparents && has_key(branch_indexes, parents[parent_index])
      parent_index += 1
    endwhile

    # Traverse branches old and new

    while branch_index < nbranches || nmerges_right > 0
      var branch_hash = get(branch_hashes, branch_index, '')
      var has_branch = !empty(branch_hash)

      var is_commit = branch_index == commit_branch_index

      # Set merge info before updates

      # Check moved index later
      var merge_up = has_branch || moved_parent_branch_index == branch_index
      const merge_left = nmerges_left > 0 && nmerges_right > 0
      var is_complex = false

      # Handle commit

      if !has_branch && commit_branch_index < 0
        # Found empty branch and commit has not yet been added
        # Add the commit in the empty branch spot

        commit_branch_index = branch_index
        is_commit = true
      endif

      if is_commit
        # Count commit merge
        nmerges_right -= 1
        nmerges_left += 1

        if has_branch
          # End of branch

          # Remove branch
          remove(branch_hashes, commit_branch_index)
          remove(branch_indexes, commit_hash)

          # Trim trailing empty branches
          while nbranches > 0 && !has_key(branch_hashes, nbranches - 1)
            nbranches -= 1
          endwhile

          # Clear branch hash
          branch_hash = ''
          has_branch = false
        endif

        # Move last parent under commit

        if nparents == 1 && parent_index == 1 && nmerges_right == 1
          # Remove the only parent to the right so it is moved under the commit

          parent_index = 0
          const parent_hash = parents[parent_index]

          # Remove old parent branch
          const parent_branch_index = remove(branch_indexes, parent_hash)
          remove(branch_hashes, parent_branch_index)

          # Trim trailing empty branches
          while nbranches > 0 && !has_key(branch_hashes, nbranches - 1)
            nbranches -= 1
          endwhile

          # Record the old index of the moved branch
          moved_parent_branch_index = parent_branch_index

          # Count upcoming moved parent as another merge
          nmerges_right += 1
        endif
      endif

      # Handle parents

      if !has_branch && parent_index < nparents
        # New parent

        const parent_hash = parents[parent_index]

        # Add parent to branch
        branch_indexes[parent_hash] = branch_index
        branch_hashes[branch_index] = parent_hash

        # Update the branch hash
        branch_hash = parent_hash
        has_branch = true

        # Update the number of branches
        if branch_index == nbranches
          nbranches += 1
        endif

        # Jump to next available parent
        parent_index += 1
        while parent_index < nparents && has_key(branch_indexes, parents[parent_index])
          parent_index += 1
        endwhile

        # Count new parent merge
        nmerges_right -= 1
        nmerges_left += 1
      elseif branch_index == moved_parent_branch_index || (nmerges_right > 0 && has_key(parent_hash_lookup, branch_hash))
        # Existing parent

        # Count existing parent merge
        nmerges_right -= 1
        nmerges_left += 1

        # Determine if parent has complex merge
        is_complex = merge_left && nmerges_right > 0
        if is_complex
          ncomplex_merges += 1
        endif
      endif

      # Draw commit lines

      if branch_index < ncommit_branches
        if is_commit
          # Record commit col
          commit_cols[commit_hash] = ncommit_cols + 1

          # Draw current commit

          commit_prefix ..= "\U1f784 "

          if ncommit_lines > 1
            if nparents > 0
              # Draw branch on multiline commit
              commit_multiline_prefix ..= "\u2502 "
            else
              # Draw empty branch on multiline commit
              commit_multiline_prefix ..= '  '
            endif
          endif
        elseif merge_up
          # Draw unrelated branch

          commit_prefix ..= "\u2502 "
          if ncommit_lines > 1
            commit_multiline_prefix ..= "\u2502 "
          endif
        else
          # Draw empty branch

          commit_prefix ..= '  '
          if ncommit_lines > 1
            commit_multiline_prefix ..= '  '
          endif
        endif

        ncommit_cols += 2
      endif

      # Draw merge lines

      if is_complex
        # Draw complex merge lines

        merge_line ..= "\u252c\u250a"
        complex_merge_line ..= "\u2570\u2524"
      else
        # Draw non-complex merge lines

        # Update merge info after drawing commit

        merge_up = merge_up || is_commit || branch_index == moved_parent_branch_index
        const merge_right = nmerges_left > 0 && nmerges_right > 0

        # Draw left character

        if branch_index > 0
          if merge_left
            # Draw left merge line
            merge_line ..= "\u2500"
          else
            # No merge to left
            # Draw empty space
            merge_line ..= ' '
          endif

          # Draw empty space
          complex_merge_line ..= ' '
        endif

        # Draw right character

        if merge_up
          if has_branch
            if merge_left
              if merge_right
                if is_commit
                  # Merge up, down, left, right
                  merge_line ..= "\u253c"
                else
                  # Jump over
                  merge_line ..= "\u250a"
                endif
              else
                # Merge up, down, left
                merge_line ..= "\u2524"
              endif
            else
              if merge_right
                # Merge up, down, right
                merge_line ..= "\u251c"
              else
                # Merge up, down
                merge_line ..= "\u2502"
              endif
            endif
          else
            if merge_left
              if merge_right
                # Merge up, left, right
                merge_line ..= "\u2534"
              else
                # Merge up, left
                merge_line ..= "\u256f"
              endif
            else
              if merge_right
                # Merge up, right
                merge_line ..= "\u2570"
              else
                # Merge up
                merge_line ..= ' '
              endif
            endif
          endif
        else
          if has_branch
            if merge_left
              if merge_right
                # Merge down, left, right
                merge_line ..= "\u252c"
              else
                # Merge down, left
                merge_line ..= "\u256e"
              endif
            else
              if merge_right
                # Merge down, right
                merge_line ..= "\u256d"
              else
                # Merge down
                # Not possible to merge down only
                throw g:flog_graph_error
              endif
            endif
          else
            if merge_left
              if merge_right
                # Merge left, right
                merge_line ..= "\u2500"
              else
                # Merge left
                # Not possible to merge left only
                throw g:flog_graph_error
              endif
            else
              if merge_right
                # Merge right
                # Not possible to merge right only
                throw g:flog_graph_error
              else
                # No merges
                merge_line ..= ' '
              endif
            endif
          endif
        endif

        # Draw complex merge line right char
        if has_branch
          complex_merge_line ..= "\u2502"
        else
          complex_merge_line ..= ' '
        endif
      endif

      # Increment

      branch_index += 1
    endwhile

    # Add output

    add(output, commit_prefix .. get(commit_content, 0, ''))
    add(line_commits, commit)
    nlines += 1
    commit_lines[commit_hash] = nlines

    var i = 1
    while i < ncommit_lines
      add(output, commit_multiline_prefix .. commit_content[i])
      add(line_commits, commit)
      nlines += 1
      i += 1
    endwhile

    if (
      nparents > 1
      || moved_parent_branch_index >= 0
      || (nparents == 0 && nbranches > 0)
      || (nparents == 1 && get(branch_indexes, parents[0]) != commit_branch_index)
      )
      add(output, merge_line)
      add(line_commits, commit)
      nlines += 1
      if ncomplex_merges > 0
        add(output, complex_merge_line)
        add(line_commits, commit)
        nlines += 1
      endif
    endif

    # Increment

    commit_index += 1
  endwhile

  return graph
enddef

# Generate the commit graph for -no-graph
def flog#graph#generate_commits_only(commits: list<dict<any>>, all_commit_content: list<list<string>>): dict<any>
  var graph = flog#graph#create()
  var output = graph.output
  var line_commits = graph.line_commits
  var commit_lines = graph.commit_lines
  var commit_cols = graph.commit_cols

  var nlines = 0
  var commit_index = 0
  const ncommits = len(commits)

  while commit_index < ncommits
    # Get commit data

    const commit = commits[commit_index]
    const commit_hash = commit.hash
    const commit_content = all_commit_content[commit_index]
    const ncommit_lines = len(commit_content)

    # Add output

    commit_cols[commit_hash] = 1

    add(output, get(commit_content, 0, ''))
    add(line_commits, commit)
    nlines += 1
    commit_lines[commit_hash] = nlines

    var i = 1
    while i < ncommit_lines
      add(output, commit_content[i])
      add(line_commits, commit)
      nlines += 1
      i += 1
    endwhile

    # Increment

    commit_index += 1
  endwhile

  return graph
enddef
