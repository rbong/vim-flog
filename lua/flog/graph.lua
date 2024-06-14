-- This script parses git log output and produces the commit graph
-- It is optimized for speed, not brevity or readability

-- Init error strings
local graph_error = 'flog: internal error drawing graph'

-- Init graph strings
local top_commit_str =    '┌ '
local middle_commit_str = '├ '
local bottom_commit_str = '└ '
local disconnected_commit_str = '• '
local commit_branch_str = '│ '
local commit_empty_str = '  '
local complex_merge_str_1 = '┬┊'
local complex_merge_str_2 = '╰┤'
local merge_all_str = '┼'
local merge_jump_str = '┊'
local merge_up_down_left_str = '┤'
local merge_up_down_right_str = '├'
local merge_up_down_str = '│'
local merge_up_left_right_str = '┴'
local merge_up_left_str = '╯'
local merge_up_right_str = '╰'
local merge_up_str = ' '
local merge_down_left_right_str = '┬'
local merge_down_left_str = '╮'
local merge_down_right_str = '╭'
local merge_left_right_str = '─'
local merge_empty_str = ' '
local missing_parent_str = '┊ '
local missing_parent_branch_str = '│ '
local missing_parent_empty_str = '  '

local function get_commit_string(is_top, is_bottom)
  if not is_top and not is_bottom then
    return middle_commit_str
  end
  if is_top and is_bottom then
    return disconnected_commit_str
  end
  if is_top then
    return top_commit_str
  end
  if is_bottom then
    return bottom_commit_str
  end
end

local function flog_get_graph(
    enable_vim,
    enable_nvim,
    enable_porcelain,
    start_token,
    enable_graph,
    cmd,
    collapsed_commits)
  -- Resolve Vim values
  enable_graph = enable_graph and enable_graph ~= 0

  -- Init commit parsing data
  local commits = {}
  local commit_hashes = {}
  local ncommits = 0

  -- Init Vim output
  local vim_out
  local vim_out_index = 1
  local vim_commits
  local vim_commits_by_hash
  local vim_line_commits

  if enable_vim then
    vim_out = vim.list()
    vim_commits = vim.list()
    vim_commits_by_hash = vim.dict()
    vim_line_commits = vim.list()
  else
    vim_out = {}
    vim_commits = {}
    vim_commits_by_hash = {}
    vim_line_commits = {}
  end

  -- Run command
  local handle = io.popen(cmd)

  -- Skip first line (start token)
  handle:read()

  -- Read hashes until EOF
  for hash in handle:lines() do
    -- Update commit count
    ncommits = ncommits + 1

    -- Save hash
    commit_hashes[hash] = 1

    -- Read and split parents
    local parents = {}
    local parent_hashes = {}
    local nparents = 0
    for parent in handle:read():gmatch('%S+') do
      if not parent_hashes[parent] then
        nparents = nparents + 1
        parents[nparents] = parent
        parent_hashes[parent] = 1
      end
    end

    -- Read refs
    local refs = handle:read()

    -- Read output until EOF or start token
    local out = {}
    local nlines = 0
    for line in handle:lines() do
      nlines = nlines + 1
      if line == start_token then
        break
      end
      out[nlines] = line
    end

    -- Save commit
    commits[ncommits] = {
      hash = hash,
      parents = parents,
      parent_hashes = parent_hashes,
      refs = refs,
      out = out,
    }
  end

  -- Output number of commits
  if not enable_vim and not enable_nvim then
    print(ncommits)
  end

  -- Init graph data
  local branch_hashes = {}
  local branch_indexes = {}
  local nbranches = 0
  -- set of commits that have children already printed
  local commit_hashes_with_children = {}

  -- Draw graph

  for commit_index, commit in ipairs(commits) do
    -- Get commit data

    local commit_hash = commit.hash
    local parents = commit.parents
    local parent_hashes = commit.parent_hashes
    local nparents = #parents
    local commit_out = commit.out
    local ncommit_lines = #commit.out

    -- Init commit output

    -- The prefix that goes before the first commit line
    local commit_prefix = {}
    -- The prefix that goes after multiline commits
    local commit_multiline_prefix = {}
    -- The number of strings in commit lines
    local ncommit_strings = 0
    -- The merge line that goes after the commit
    local merge_line = {}
    -- The complex merge line that goes after the merge
    local complex_merge_line = {}
    -- The number of strings in merge lines
    local nmerge_strings = 0
    -- The two lines indicating missing parents after the complex line
    local missing_parents_line_1 = {}
    local missing_parents_line_2 = {}
    -- The number of strings in missing parent lines
    local nmissing_parents_strings = 0

    -- Init visual data

    -- The number of columns in the commit output
    local ncommit_cols = 0
    -- The visual column which the commit branch is on
    local commit_branch_col = 0
    -- The parents in the order they appear in the graph
    local visual_parents
    -- The number of visual parents
    local nvisual_parents = 0
    -- The number of complex merges (octopus)
    local ncomplex_merges = 0
    -- The number of missing parents
    local nmissing_parents = 0

    if enable_vim then
      visual_parents = vim.list()
    else
      visual_parents = {}
    end

    -- Init graph data

    -- The number of passed merges
    local nmerges_left = 0
    -- The number of upcoming merges (parents + commit)
    local nmerges_right = nparents + 1
    -- The index of the commit branch
    local commit_branch_index = branch_indexes[commit_hash]
    -- The index of the moved parent branch (there is only one)
    local moved_parent_branch_index = nil
    -- The number of branches on the commit line
    local ncommit_branches = nbranches + (commit_branch_index and 0 or 1)

    -- Init indexes

    -- The current branch
    local branch_index = 1
    -- The current parent
    local parent_index = 1

    -- Find the first empty parent
    while parent_index <= nparents and branch_indexes[parents[parent_index]] do
      parent_index = parent_index + 1
    end

    -- Mark parent commits as mentioned
    for _, parent_hash in ipairs(parents) do
      commit_hashes_with_children[parent_hash] = true
    end

    -- Traverse old and new branches

    if enable_graph then
      while branch_index <= nbranches or nmerges_right > 0 do
        -- Get branch data

        local branch_hash = branch_hashes[branch_index]
        local is_commit = branch_index == commit_branch_index

        -- Set merge info before updates

        local merge_up = branch_hash or moved_parent_branch_index == branch_index
        local merge_left = nmerges_left > 0 and nmerges_right > 0
        local is_complex = false
        local is_missing_parent = false

        -- Handle commit

        if not branch_hash and not commit_branch_index then
          -- Found empty branch and commit does not have a branch
          -- Add the commit in the empty spot

          commit_branch_index = branch_index
          is_commit = true
        end

        local current_commit_str
        if is_commit then
          -- identify symbol to draw for commit
          local is_top = commit_hashes_with_children[commit_hash] == nil
          local is_bottom = nparents == 0
          current_commit_str = get_commit_string(is_top, is_bottom)

          -- Count commit merge
          nmerges_right = nmerges_right - 1
          nmerges_left = nmerges_left + 1

          -- Record commit col
          commit_branch_col = ncommit_cols + 1

          if branch_hash then
            -- End of branch

            -- Remove branch
            branch_hashes[commit_branch_index] = nil
            branch_indexes[commit_hash] = nil

            -- Trim trailing empty branches
            while nbranches > 0 and not branch_hashes[nbranches] do
              nbranches = nbranches - 1
            end

            -- Clear branch hash
            branch_hash = nil
          end

          if parent_index > nparents and nmerges_right == 1 then
            -- There is only one remaining parent, to the right
            -- Move it under the commit

            -- Find parent to right
            parent_index = nparents
            while (branch_indexes[parents[parent_index]] or -1) < branch_index do
              parent_index = parent_index - 1
            end

            -- Get parent data
            local parent_hash = parents[parent_index]
            local parent_branch_index = branch_indexes[parent_hash]

            -- Remove old parent branch
            branch_hashes[parent_branch_index] = nil
            branch_indexes[parent_hash] = nil

            -- Trim trailing empty branches
            while nbranches > 0 and not branch_hashes[nbranches] do
              nbranches = nbranches - 1
            end

            -- Record the old index
            moved_parent_branch_index = parent_branch_index

            -- Count upcoming moved parent as another merge
            nmerges_right = nmerges_right + 1
          end
        end

        -- Handle parents

        if not branch_hash and parent_index <= nparents then
          -- New parent

          -- Get parent data
          local parent_hash = parents[parent_index]

          -- Set branch to parent
          branch_indexes[parent_hash] = branch_index
          branch_hashes[branch_index] = parent_hash

          -- Update branch hash
          branch_hash = parent_hash

          -- Update the number of branches
          if branch_index > nbranches then
            nbranches = branch_index
          end

          -- Jump to next available parent
          parent_index = parent_index + 1
          while parent_index <= nparents and branch_indexes[parents[parent_index]] do
            parent_index = parent_index + 1
          end

          -- Count new parent merge
          nmerges_right = nmerges_right - 1
          nmerges_left = nmerges_left + 1

          -- Determine if parent is missing
          if branch_hash and not commit_hashes[parent_hash] then
            is_missing_parent = true
            nmissing_parents = nmissing_parents + 1
          end

          -- Record the visual parent
          nvisual_parents = nvisual_parents + 1
          visual_parents[nvisual_parents] = parent_hash
        elseif branch_index == moved_parent_branch_index or (nmerges_right > 0 and parent_hashes[branch_hash]) then
          -- Existing parents

          -- Count existing parent merge
          nmerges_right = nmerges_right - 1
          nmerges_left = nmerges_left + 1

          -- Determine if parent has a complex merge
          is_complex = merge_left and nmerges_right > 0
          if is_complex then
            ncomplex_merges = ncomplex_merges + 1
          end

          -- Determine if parent is missing
          if branch_hash and not commit_hashes[branch_hash] then
            is_missing_parent = true
            nmissing_parents = nmissing_parents + 1
          end

          if branch_index ~= moved_parent_branch_index then
            -- Record the visual parent
            nvisual_parents = nvisual_parents + 1
            visual_parents[nvisual_parents] = branch_hash
          end
        end

        -- Draw commit lines

        if branch_index <= ncommit_branches then
          -- Update commit visual info

          ncommit_cols = ncommit_cols + 2
          ncommit_strings = ncommit_strings + 1

          if is_commit then
            -- Draw current commit

            commit_prefix[ncommit_strings] = current_commit_str

            if ncommit_lines > 1 then
              if nparents > 0 then
                -- Draw branch on multiline commit
                commit_multiline_prefix[ncommit_strings] = commit_branch_str
              else
                -- Draw empty branch on multiline commit
                commit_multiline_prefix[ncommit_strings] = commit_empty_str
              end
            end
          elseif merge_up then
            -- Draw unrelated branch

            commit_prefix[ncommit_strings] = commit_branch_str
            if ncommit_lines > 1 then
              commit_multiline_prefix[ncommit_strings] = commit_branch_str
            end
          else
            -- Draw empty branch

            commit_prefix[ncommit_strings] = commit_empty_str
            if ncommit_lines > 1 then
              commit_multiline_prefix[ncommit_strings] = commit_empty_str
            end
          end
        end

        -- Update merge visual info

        nmerge_strings = nmerge_strings + 1

        -- Draw merge lines

        if is_complex then
          -- Draw merge lines for complex merge

          merge_line[nmerge_strings] = complex_merge_str_1
          complex_merge_line[nmerge_strings] = complex_merge_str_2
        else
          -- Draw non-complex merge lines

          -- Update merge info after drawing commit

          merge_up = merge_up or is_commit or branch_index == moved_parent_branch_index
          local merge_right = nmerges_left > 0 and nmerges_right > 0

          -- Draw left character

          if branch_index > 1 then
            if merge_left then
              -- Draw left merge line
              merge_line[nmerge_strings] = merge_left_right_str
            else
              -- No merge to left
              -- Draw empty space
              merge_line[nmerge_strings] = merge_empty_str
            end
            -- Complex merge line always has empty space here
            complex_merge_line[nmerge_strings] = merge_empty_str

            -- Update visual merge info

            nmerge_strings = nmerge_strings + 1
          end

          -- Draw right character

          if merge_up then
            if branch_hash then
              if merge_left then
                if merge_right then
                  if is_commit then
                    -- Merge up, down, left, right
                    merge_line[nmerge_strings] = merge_all_str
                  else
                    -- Jump over
                    merge_line[nmerge_strings] = merge_jump_str
                  end
                else
                  -- Merge up, down, left
                  merge_line[nmerge_strings] = merge_up_down_left_str
                end
              else
                if merge_right then
                  -- Merge up, down, right
                  merge_line[nmerge_strings] = merge_up_down_right_str
                else
                  -- Merge up, down
                  merge_line[nmerge_strings] = merge_up_down_str
                end
              end
            else
              if merge_left then
                if merge_right then
                  -- Merge up, left, right
                  merge_line[nmerge_strings] = merge_up_left_right_str
                else
                  -- Merge up, left
                  merge_line[nmerge_strings] = merge_up_left_str
                end
              else
                if merge_right then
                  -- Merge up, right
                  merge_line[nmerge_strings] = merge_up_right_str
                else
                  -- Merge up
                  merge_line[nmerge_strings] = merge_up_str
                end
              end
            end
          else
            if branch_hash then
              if merge_left then
                if merge_right then
                  -- Merge down, left, right
                  merge_line[nmerge_strings] = merge_down_left_right_str
                else
                  -- Merge down, left
                  merge_line[nmerge_strings] = merge_down_left_str
                end
              else
                if merge_right then
                  -- Merge down, right
                  merge_line[nmerge_strings] = merge_down_right_str
                else
                  -- Merge down
                  -- Not possible to merge down only
                  error(graph_error)
                end
              end
            else
              if merge_left then
                if merge_right then
                  -- Merge left, right
                  merge_line[nmerge_strings] = merge_left_right_str
                else
                  -- Merge left
                  -- Not possible to merge left only
                  error(graph_error)
                end
              else
                if merge_right then
                  -- Merge right
                  -- Not possible to merge right only
                  error(graph_error)
                else
                  -- No merges
                  merge_line[nmerge_strings] = merge_empty_str
                end
              end
            end
          end

          -- Draw complex right char

          if branch_hash then
            complex_merge_line[nmerge_strings] = merge_up_down_str
          else
            complex_merge_line[nmerge_strings] = merge_empty_str
          end
        end

        -- Update visual missing parents info

        nmissing_parents_strings = nmissing_parents_strings + 1

        -- Draw missing parents lines

        if is_missing_parent then
          missing_parents_line_1[nmissing_parents_strings] = missing_parent_str
          missing_parents_line_2[nmissing_parents_strings] = missing_parent_empty_str
        elseif branch_hash then
          missing_parents_line_1[nmissing_parents_strings] = missing_parent_branch_str
          missing_parents_line_2[nmissing_parents_strings] = missing_parent_branch_str
        else
          missing_parents_line_1[nmissing_parents_strings] = missing_parent_empty_str
          missing_parents_line_2[nmissing_parents_strings] = missing_parent_empty_str
        end

        -- Remove missing parent

        if is_missing_parent and branch_index ~= moved_parent_branch_index then
          -- Remove branch
          branch_hashes[branch_index] = nil
          branch_indexes[branch_hash] = nil

          -- Trim trailing empty branches
          while nbranches > 0 and not branch_hashes[nbranches] do
            nbranches = nbranches - 1
          end
        end

        -- Increment

        branch_index = branch_index + 1
      end
    end

    -- Output

    -- Calculate format column

    local format_col = ncommit_cols + 1

    -- Calculate whether certain lines should be outputted

    local should_out_merge = enable_graph and (nparents > 1
      or moved_parent_branch_index
      or (nparents == 0 and nbranches == 0)
      or (nparents == 1 and branch_indexes[parents[1]] ~= commit_branch_index))
    local should_out_complex = should_out_merge and ncomplex_merges > 0
    local should_out_missing_parents = nmissing_parents > 0

    if enable_vim or enable_nvim then
      -- Output using Vim

      -- Init Vim commit
      local vim_commit
      if enable_vim then
        vim_commit = vim.dict()
      else
        vim_commit = {}
      end

      -- Set commit details
      vim_commit.hash = commit_hash
      vim_commit.parents = visual_parents
      vim_commit.refs = commit.refs
      vim_commit.line = vim_out_index
      vim_commit.col = commit_branch_col
      vim_commit.format_col = format_col
      vim_commit.len = ncommit_lines

      -- Initialize commit objects
      local vim_commit_body
      local vim_commit_suffix
      local vim_commit_suffix_index = 1
      if enable_vim then
        vim_commit_body = vim.dict()
        vim_commit_suffix = vim.dict()
      else
        vim_commit_body = {}
        vim_commit_suffix = {}
      end
      vim_commit.body = vim_commit_body
      vim_commit.suffix = vim_commit_suffix

      -- Add commit data
      vim_commits[commit_index] = vim_commit
      vim_commits_by_hash[commit_hash] = vim_commit

      -- Add commit subject line

      vim_line_commits[vim_out_index] = vim_commit

      vim_commit.subject = table.concat(commit_prefix, '') .. commit_out[1]
      vim_out[vim_out_index] = vim_commit.subject
      vim_out_index = vim_out_index + 1

      -- Add commit body line

      if ncommit_lines > 1 then
        local prefix = table.concat(commit_multiline_prefix, '')
        local commit_out_index = 2
        local collapsed = collapsed_commits[commit_hash]

        vim_commit.collapsed_body = prefix .. string.format('== %d hidden lines ==', ncommit_lines - 1)

        if collapsed then
          vim_line_commits[vim_out_index] = vim_commit
          vim_out[vim_out_index] = vim_commit.collapsed_body
          vim_out_index = vim_out_index + 1
        end

        while commit_out_index <= ncommit_lines do
          vim_commit_body[commit_out_index - 1] = prefix .. commit_out[commit_out_index]

          if not collapsed then
            vim_line_commits[vim_out_index] = vim_commit
            vim_out[vim_out_index] = vim_commit_body[commit_out_index - 1]
            vim_out_index = vim_out_index + 1
          end

          commit_out_index = commit_out_index + 1
        end
      end

      -- Add merge lines

      if should_out_merge then
        vim_line_commits[vim_out_index] = vim_commit

        vim_commit_suffix[vim_commit_suffix_index] = table.concat(merge_line, '')
        vim_out[vim_out_index] = vim_commit_suffix[vim_commit_suffix_index]

        vim_out_index = vim_out_index + 1
        vim_commit_suffix_index = vim_commit_suffix_index + 1

        if should_out_complex then
          vim_line_commits[vim_out_index] = vim_commit

          vim_commit_suffix[vim_commit_suffix_index] = table.concat(complex_merge_line, '')
          vim_out[vim_out_index] = vim_commit_suffix[vim_commit_suffix_index]

          vim_out_index = vim_out_index + 1
          vim_commit_suffix_index = vim_commit_suffix_index + 1
        end
      end

      -- Add missing parents lines

      if should_out_missing_parents then
        vim_line_commits[vim_out_index] = vim_commit

        vim_commit_suffix[vim_commit_suffix_index] = table.concat(missing_parents_line_1, '')
        vim_out[vim_out_index] = vim_commit_suffix[vim_commit_suffix_index]

        vim_out_index = vim_out_index + 1
        vim_commit_suffix_index = vim_commit_suffix_index + 1

        vim_line_commits[vim_out_index] = vim_commit

        vim_commit_suffix[vim_commit_suffix_index] = table.concat(missing_parents_line_2, '')
        vim_out[vim_out_index] = vim_commit_suffix[vim_commit_suffix_index]

        vim_out_index = vim_out_index + 1
        vim_commit_suffix_index = vim_commit_suffix_index + 1
      end

      -- Calculate number of extra lines
      vim_commit.suffix_len = vim_commit_suffix_index - 1
    else
      -- Output using stdout

      if enable_porcelain then
        -- Print commit hash
        print(commit_hash)

        -- Print commit visual parents
        print(nvisual_parents)
        for _, parent in ipairs(visual_parents) do
          print(parent)
        end

        -- Print commit refs
        print(commit.refs)

        -- Print commit col
        print(commit_branch_col)

        -- Print commit format start
        print(format_col)

        -- Print commit length
        print(ncommit_lines)

        -- Print suffix length
        print((should_out_merge and 1 or 0)
          + (should_out_complex and 1 or 0)
          + (should_out_missing_parents and 2 or 0))

        -- Print collapsed format
        if ncommit_lines > 1 then
          for _, str in ipairs(commit_multiline_prefix) do
            io.write(str)
          end
          io.write(string.format('== %d hidden lines ==\n', ncommit_lines - 1))
        end
      end

      -- Print commit out

      for _, str in ipairs(commit_prefix) do
        io.write(str)
      end
      io.write(commit_out[1])
      io.write('\n')

      local commit_line = 2
      while commit_line <= ncommit_lines do
        for _, str in ipairs(commit_multiline_prefix) do
          io.write(str)
        end
        io.write(commit_out[commit_line])
        io.write('\n')
        commit_line = commit_line + 1
      end

      -- Print merge out

      if should_out_merge then
        for _, str in ipairs(merge_line) do
          io.write(str)
        end
        io.write('\n')

        if should_out_complex then
          for _, str in ipairs(complex_merge_line) do
            io.write(str)
          end
          io.write('\n')
        end
      end

      -- Print missing parents out

      if should_out_missing_parents then
        for _, str in ipairs(missing_parents_line_1) do
          io.write(str)
        end
        io.write('\n')

        for _, str in ipairs(missing_parents_line_2) do
          io.write(str)
        end
        io.write('\n')
      end
    end
  end

  if enable_vim or enable_nvim then
    local dict_out = {
      output = vim_out,
      commits = vim_commits,
      commits_by_hash = vim_commits_by_hash,
      line_commits = vim_line_commits,
    }

    if enable_vim then
      return vim.dict(dict_out)
    else
      return dict_out
    end
  end
end

local function flog_update_graph(
    enable_nvim,
    graph,
    collapsed_commits)
  -- Init data
  local commits = graph.commits
  local commit_index = 1
  local commits_by_hash = graph.commits_by_hash
  local line_commits
  local output
  local total_lines = 1

  if not enable_nvim then
    line_commits = vim.list()
    output = vim.list()
  else
    line_commits = {}
    output = {}
  end

  -- Find number of commits
  local ncommits = #commits

  -- Rebuild output/line commits
  while commit_index <= ncommits do
    local commit = commits[commit_index]
    local hash = commit.hash
    local len = commit.len
    local suffix_len = commit.suffix_len

    -- Update line position
    commit.line = total_lines

    if enable_nvim then
      -- Re-record commit
      commits_by_hash[hash] = commit
    end

    -- Add subject
    output[total_lines] = commit.subject
    line_commits[total_lines] = commit
    total_lines = total_lines + 1

    if len > 1 then
      if collapsed_commits[hash] then
        -- Add collapsed body
        output[total_lines] = commit.collapsed_body
        line_commits[total_lines] = commit
        total_lines = total_lines + 1
      else
        -- Add body
        local body_index = 1
        local body = commit.body
        while body_index < len do
          output[total_lines] = body[body_index]
          line_commits[total_lines] = commit
          body_index = body_index + 1
          total_lines = total_lines + 1
        end
      end
    end

    if suffix_len > 0 then
      -- Add suffix
      local suffix_index = 1
      local suffix = commit.suffix
      while suffix_index <= suffix_len do
        output[total_lines] = suffix[suffix_index]
        line_commits[total_lines] = commit
        suffix_index = suffix_index + 1
        total_lines = total_lines + 1
      end
    end

    -- Increment
    commit_index = commit_index + 1
  end

  -- Return
  local dict_out = {
    output = output,
    commits = commits,
    commits_by_hash = commits_by_hash,
    line_commits = line_commits,
  }
  if enable_nvim then
    return dict_out
  else
    return vim.dict(dict_out)
  end
end

_G.flog_get_graph = flog_get_graph
_G.flog_update_graph = flog_update_graph
