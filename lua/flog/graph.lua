-- This script parses git log output and produces the commit graph
-- It is optimized for speed, not brevity or readability

local function flog_get_graph(
    enable_vim,
    enable_nvim,
    enable_porcelain,
    start_token,
    enable_extended_chars,
    enable_extra_padding,
    enable_graph,
    default_collapsed,
    cmd,
    collapsed_commits)
  -- Resolve Vim values
  enable_graph = enable_graph and enable_graph ~= 0
  default_collapsed = default_collapsed and default_collapsed ~= 0
  enable_extended_chars = enable_extended_chars and enable_extended_chars ~= 0
  enable_extra_padding = enable_extra_padding and enable_extra_padding ~= 0
  local enable_vim_out = enable_vim or enable_nvim

  -- Init graph strings
  local branch_str = '│ '
  local horizontal_str = '──'
  local branch_horizontal_str = '│─'
  local branch_fade_str = '┊ '
  local upper_left_corner_str = '╯ '
  local upper_right_corner_str = '╰─'
  local lower_left_corner_str = '╮ '
  local lower_right_corner_str = '╭─'
  local disconnected_commit_str = '• '
  local initial_commit_str = '• '
  local branch_commit_str = '• '
  local branch_merge_commit_str = '• '
  local branch_tip_commit_str = '• '
  local branch_tip_merge_commit_str = '• '
  local merge_left_str = '┬─'
  local merge_right_str = '┬─'
  local merge_up_str = '┴─'
  local merge_branch_left_str = '┤ '
  local fork_branch_left_str = '┤ '
  local fork_branch_left_horizontal_str = '┤─'
  local merge_branch_right_str = '├─'
  local fork_branch_right_str = '├─'
  local merge_up_branch_str = '┼─'
  local merge_fork_branch_str = '┼─'
  local empty_branch_str = '  '

  -- Use extended graph strings
  if enable_extended_chars then
    branch_str = ' '
    horizontal_str = ''
    branch_horizontal_str = ''
    branch_fade_str = ' '
    upper_left_corner_str = ' '
    upper_right_corner_str = ''
    lower_left_corner_str = ' '
    lower_right_corner_str = ''
    disconnected_commit_str = ' '
    initial_commit_str = ' '
    branch_commit_str = ' '
    branch_merge_commit_str = ' '
    branch_tip_commit_str = ' '
    branch_tip_merge_commit_str = ' '
    merge_left_str = ''
    merge_right_str = ''
    merge_up_str = ''
    merge_branch_left_str = ' '
    fork_branch_left_str = ' '
    fork_branch_left_horizontal_str = ''
    merge_branch_right_str = ''
    fork_branch_right_str = ''
    merge_up_branch_str = ''
    merge_fork_branch_str = ''
  end

  -- Init commit parsing data
  local commits = {}
  local last_hash_appearance = {}
  local ncommits = 0

  -- Init Vim output
  local vim_out
  local out_line = 1
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

  -- Read commits until EOF
  for hash in handle:lines() do
    -- Update commit count
    ncommits = ncommits + 1

    -- Record commit
    last_hash_appearance[hash] = ncommits

    -- Read and split parents
    local new_parents = {}
    local nnew_parents = 0
    local existing_parent_hashes = {}
    local nexisting_parents = 0
    for parent_hash in handle:read():gmatch('%S+') do
      if not last_hash_appearance[parent_hash] then
        nnew_parents = nnew_parents + 1
        new_parents[nnew_parents] = parent_hash
      elseif not existing_parent_hashes[parent_hash] then
        nexisting_parents = nexisting_parents + 1
        existing_parent_hashes[parent_hash] = 1
      end
      last_hash_appearance[parent_hash] = ncommits
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
      new_parents = new_parents,
      nnew_parents = nnew_parents,
      existing_parent_hashes = existing_parent_hashes,
      nexisting_parents = nexisting_parents,
      refs = refs,
      out = out,
    }
  end

  -- Output number of commits
  if not enable_vim_out and enable_porcelain then
    print(ncommits)
  end

  -- Init graph data
  local branch_hashes = {}
  local branch_indexes = {}
  local branch_out = {}
  local graph_width = 0

  -- Draw graph

  for commit_index, commit in ipairs(commits) do
    -- Get commit data

    local commit_hash = commit.hash
    local commit_new_parents = commit.new_parents
    local ncommit_new_parents = commit.nnew_parents
    local commit_existing_parent_hashes = commit.existing_parent_hashes
    local ncommit_existing_parents = commit.nexisting_parents
    local ncommit_parents = ncommit_new_parents + ncommit_existing_parents
    local commit_out = commit.out
    local ncommit_lines = #commit.out

    -- Init output data

    local commit_branch_index
    local commit_graph_width

    local commit_col
    local commit_format_col
    local commit_merge_col
    local commit_merge_end_col

    local commit_subject_line
    local commit_multiline_prefix
    local commit_collapsed_body = string.format('== %d hidden lines ==', ncommit_lines - 1)
    local merge_line
    local missing_parents_line

    local missing_parents = {}
    local nmissing_parents = 0

    local vim_commit_parents
    local nvim_parents = 0
    if enable_vim then
      vim_commit_parents = vim.list()
    else
      vim_commit_parents = {}
    end

    local should_out_merge_line = false
    local should_pad = enable_extra_padding

    -- Commit collapsed state
    local commit_collapsed = collapsed_commits[commit_hash]
    if commit_collapsed == nil then
      commit_collapsed = default_collapsed
    end

    -- Build commit output

    local commit_str

    if enable_graph then
      -- Find commit branch
      commit_branch_index = branch_indexes[commit_hash]

      if commit_branch_index ~= nil then
        -- Handle commit on existing branch

        -- Remove branch
        branch_out[commit_branch_index] = empty_branch_str
        branch_hashes[commit_branch_index] = nil

        -- Resize graph width for removed commit branch
        while graph_width > 0 and branch_hashes[graph_width] == nil do
          graph_width = graph_width - 1
        end

        -- Set commit char for commit on existing branch
        if ncommit_parents > 1 then
          commit_str = branch_merge_commit_str
        elseif ncommit_parents == 1 then
          commit_str = branch_commit_str
        else
          commit_str = initial_commit_str
        end
      else
        -- Handle commit on new branch

        -- Find first available branch for commit
        commit_branch_index = 1
        while branch_hashes[commit_branch_index] ~= nil do
          commit_branch_index = commit_branch_index + 1
        end

        -- Set commit char for commit on new branch
        if ncommit_parents > 1 then
          commit_str = branch_tip_merge_commit_str
        elseif ncommit_parents == 1 then
          commit_str = branch_tip_commit_str
        else
          commit_str = disconnected_commit_str
        end
      end

      -- Get graph width of commit
      if commit_branch_index > graph_width then
        commit_graph_width = commit_branch_index
      else
        commit_graph_width = graph_width
      end

      -- Set up commit output
      branch_out[commit_branch_index] = commit_str
      branch_out[commit_graph_width + 1] = commit_out[1]
      -- Draw commit output
      commit_subject_line = table.concat(branch_out, '', 1, commit_graph_width + 1)
      -- Clean up branch output
      branch_out[commit_graph_width + 1] = empty_branch_str
      branch_out[commit_branch_index] = empty_branch_str

      -- Build multiline prefix
      if ncommit_lines > 1 then
        -- Set up multiline prefix
        if ncommit_parents > 0 then
          branch_out[commit_branch_index] = branch_str
        end
        -- Draw multiline prefix
        commit_multiline_prefix = table.concat(branch_out, '', 1, commit_graph_width)
        -- Clean up branch output
        branch_out[commit_branch_index] = empty_branch_str
      end

      -- Clean up branch output
      branch_out[commit_branch_index] = empty_branch_str
    else
      commit_branch_index = 1
      commit_graph_width = 0
      commit_subject_line = commit_out[1]
      commit_multiline_prefix = ''
    end

    -- Calculate commit column
    commit_col = 1 + 2 * (commit_branch_index - 1)
    commit_format_col = 1 + 2 * commit_graph_width

    -- Output subsequent graph lines

    if enable_graph then
      if ncommit_parents > 0 then
        -- Build merge line and update branch data

        -- Enable merge line
        should_out_merge_line = true

        -- Init merge output
        local merge_out = {}
        local merge_out_index = 1
        local new_parent_index = 1
        local nexisting_parents_found = 0

        -- Find start of merge
        commit_merge_col = 1
        while commit_merge_col < commit_branch_index do
          local branch_hash = branch_hashes[commit_merge_col]
          if branch_hash == nil then
            if ncommit_new_parents > 0 then
              break
            end
          elseif commit_existing_parent_hashes[branch_hash] then
            break
          end
          commit_merge_col = commit_merge_col + 1
        end

        -- Handle parents to left of commit
        local merge_branch_index = commit_merge_col
        while merge_branch_index < commit_branch_index do
          local merge_branch_hash = branch_hashes[merge_branch_index]

          if merge_branch_hash == nil then
            -- Handle new parent

            if new_parent_index <= ncommit_new_parents then
              local new_parent_hash = commit_new_parents[new_parent_index]
              new_parent_index = new_parent_index + 1

              -- Place new parent branch
              branch_hashes[merge_branch_index] = new_parent_hash
              branch_indexes[new_parent_hash] = merge_branch_index

              -- Draw new parent branch
              branch_out[merge_branch_index] = branch_str

              -- Record visual parent
              nvim_parents = nvim_parents + 1
              vim_commit_parents[nvim_parents] = new_parent_hash

              -- Record missing parent
              if commit_index == last_hash_appearance[new_parent_hash] then
                nmissing_parents = nmissing_parents + 1
                missing_parents[nmissing_parents] = new_parent_hash
              end

              -- Parent
              if merge_branch_index == commit_merge_col then
                -- Draw first new parent merging to right
                merge_out[merge_out_index] = lower_right_corner_str
              else
                -- Draw new parent merging to right
                merge_out[merge_out_index] = merge_right_str
              end
            else
              -- Draw continuing merge from left
              merge_out[merge_out_index] = horizontal_str
            end
          elseif commit_existing_parent_hashes[merge_branch_hash] then
            -- Handle existing parent

            nexisting_parents_found = nexisting_parents_found + 1

            -- Record visual parent
            nvim_parents = nvim_parents + 1
            vim_commit_parents[nvim_parents] = merge_branch_hash

            -- Record missing parent
            if commit_index == last_hash_appearance[merge_branch_hash] then
              nmissing_parents = nmissing_parents + 1
              missing_parents[nmissing_parents] = merge_branch_hash
            end

            -- Draw existing parent merging to right
            merge_out[merge_out_index] = fork_branch_right_str
          else
            -- Draw unrelated branch
            merge_out[merge_out_index] = branch_horizontal_str
          end

          merge_branch_index = merge_branch_index + 1
          merge_out_index = merge_out_index + 1
        end

        -- Handle parent under commit
        local should_move_last_parent_under_commit = false
        if new_parent_index <= ncommit_new_parents then
          -- Add a new parent under the commit

          local new_parent_hash = commit_new_parents[new_parent_index]
          new_parent_index = new_parent_index + 1

          -- Place new parent branch
          branch_hashes[commit_branch_index] = new_parent_hash
          branch_indexes[new_parent_hash] = commit_branch_index

          -- Draw new parent branch
          branch_out[merge_branch_index] = branch_str

          -- Update graph width
          if merge_branch_index > graph_width then
            graph_width = merge_branch_index
          end

          -- Record visual parent
          nvim_parents = nvim_parents + 1
          vim_commit_parents[nvim_parents] = new_parent_hash

          -- Record missing parent
          if commit_index == last_hash_appearance[new_parent_hash] then
            nmissing_parents = nmissing_parents + 1
            missing_parents[nmissing_parents] = new_parent_hash
          end

          -- Abort merge if there is only a single commit under the parent
          should_out_merge_line = ncommit_parents ~= 1
        elseif ncommit_existing_parents - nexisting_parents_found == 1 then
          -- Move the last existing parent under the commit
          should_move_last_parent_under_commit = true
        end

        if should_out_merge_line then
          -- Disable padding, not needed with extra merge line
          should_pad = false

          -- Draw commit merge string
          if commit_merge_col == commit_branch_index then
            -- Draw merge start at commit
            if branch_hashes[commit_branch_index] then
              merge_out[merge_out_index] = merge_branch_right_str
            elseif should_move_last_parent_under_commit then
              merge_out[merge_out_index] = fork_branch_right_str
            else
              merge_out[merge_out_index] = upper_right_corner_str
            end
          elseif new_parent_index > ncommit_new_parents and nexisting_parents_found == ncommit_existing_parents then
            -- Draw merge end at commit
            if branch_hashes[commit_branch_index] then
              merge_out[merge_out_index] = merge_branch_left_str
            else
              merge_out[merge_out_index] = upper_left_corner_str
            end
          else
            -- Draw merge from left and right into commit
            if branch_hashes[commit_branch_index] then
              merge_out[merge_out_index] = merge_up_branch_str
            elseif should_move_last_parent_under_commit then
              merge_out[merge_out_index] = merge_fork_branch_str
            else
              merge_out[merge_out_index] = merge_up_str
            end
          end

          -- Handle parents to right of commit
          while nexisting_parents_found + new_parent_index <= ncommit_parents do
            merge_branch_index = merge_branch_index + 1
            merge_out_index = merge_out_index + 1
            local merge_branch_hash = branch_hashes[merge_branch_index]

            if merge_branch_hash == nil then
              -- Handle new parent

              if new_parent_index <= ncommit_new_parents then
                local new_parent_hash = commit_new_parents[new_parent_index]
                new_parent_index = new_parent_index + 1

                -- Place new parent branch
                branch_hashes[merge_branch_index] = new_parent_hash
                branch_indexes[new_parent_hash] = merge_branch_index

                -- Draw new parent branch
                branch_out[merge_branch_index] = branch_str

                -- Update graph width
                if merge_branch_index > graph_width then
                  graph_width = merge_branch_index
                end

                -- Record visual parent
                nvim_parents = nvim_parents + 1
                vim_commit_parents[nvim_parents] = new_parent_hash

                -- Record missing parent
                if commit_index == last_hash_appearance[new_parent_hash] then
                  nmissing_parents = nmissing_parents + 1
                  missing_parents[nmissing_parents] = new_parent_hash
                end

                -- Draw parent
                if nexisting_parents_found + new_parent_index > ncommit_parents then
                  -- Draw last new parent merging to left
                  merge_out[merge_out_index] = lower_left_corner_str
                else
                  -- Draw new parent merging to left
                  merge_out[merge_out_index] = merge_left_str
                end
              else
                -- Draw continuing merge from left
                merge_out[merge_out_index] = horizontal_str
              end
            elseif commit_existing_parent_hashes[merge_branch_hash] then
              -- Handle existing parent

              nexisting_parents_found = nexisting_parents_found + 1

              -- Record visual parent
              nvim_parents = nvim_parents + 1
              vim_commit_parents[nvim_parents] = merge_branch_hash

              -- Record missing parent
              if commit_index == last_hash_appearance[merge_branch_hash] then
                nmissing_parents = nmissing_parents + 1
                missing_parents[nmissing_parents] = merge_branch_hash
              end

              -- Draw parent
              if should_move_last_parent_under_commit then
                -- Draw moved parent
                merge_out[merge_out_index] = upper_left_corner_str
              elseif nexisting_parents_found + new_parent_index > ncommit_parents then
                -- Draw last existing parent merging to left
                merge_out[merge_out_index] = fork_branch_left_str
              else
                -- Draw existing parent merging to left
                merge_out[merge_out_index] = fork_branch_left_horizontal_str
              end
            else
              -- Draw unrelated branch
              merge_out[merge_out_index] = branch_horizontal_str
            end
          end

          -- Store merge end column
          commit_merge_end_col = merge_branch_index

          -- Build merge line
          merge_line = (
            table.concat(branch_out, '', 1, commit_merge_col - 1)
            .. table.concat(merge_out, '')
            .. table.concat(branch_out, '', merge_branch_index + 1, graph_width))

          if should_move_last_parent_under_commit then
            -- Move parent under commit
            local moved_hash = branch_hashes[merge_branch_index]
            branch_out[merge_branch_index] = empty_branch_str
            branch_hashes[merge_branch_index] = nil
            branch_out[commit_branch_index] = branch_str
            branch_hashes[commit_branch_index] = moved_hash
            branch_indexes[moved_hash] = commit_branch_index

            -- Resize graph width after moving parent under commit
            while graph_width > 0 and branch_hashes[graph_width] == nil do
              graph_width = graph_width - 1
            end
          end
        end
      end

      if nmissing_parents > 0 then
        -- Handle missing parents

        -- Missing parents require padding to separate branch lines
        should_pad = true

        -- Set fading parent branch strings
        local missing_parents_index = 1
        while missing_parents_index <= nmissing_parents do
          local parent_branch_index = branch_indexes[missing_parents[missing_parents_index]]
          branch_out[parent_branch_index] = branch_fade_str
          missing_parents_index = missing_parents_index + 1
        end

        -- Build missing parents output
        missing_parents_line = table.concat(branch_out, '', 1, graph_width)

        -- Remove missing parents
        missing_parents_index = 1
        while missing_parents_index <= nmissing_parents do
          local parent_branch_index = branch_indexes[missing_parents[missing_parents_index]]
          branch_out[parent_branch_index] = '  '
          branch_hashes[parent_branch_index] = nil
          missing_parents_index = missing_parents_index + 1
        end

        -- Resize graph width for removed missing parents
        while graph_width > 0 and branch_hashes[graph_width] == nil do
          graph_width = graph_width - 1
        end
      end
    end

    -- Output commit
    if enable_vim_out then
      -- Init vim commit output
      local vim_commit
      local vim_commit_body
      local vim_commit_suffix
      if enable_vim then
        vim_commit = vim.dict()
        vim_commit_body = vim.dict()
        vim_commit_suffix = vim.dict()
      else
        vim_commit = {}
        vim_commit_body = {}
        vim_commit_suffix = {}
      end
      local vim_commit_index = commit_index - 1
      vim_commit.body = vim_commit_body
      vim_commit.suffix = vim_commit_suffix

      -- Set commit details
      vim_commit.hash = commit_hash
      vim_commit.parents = vim_commit_parents
      vim_commit.refs = commit.refs
      vim_commit.line = out_line
      vim_commit.col = commit_col
      vim_commit.format_col = commit_format_col
      vim_commit.len = ncommit_lines

      -- Draw commit subject
      vim_commit.subject = commit_subject_line
      vim_line_commits[out_line] = vim_commit_index
      vim_out[out_line] = vim_commit.subject
      out_line = out_line + 1

      -- Draw multiline output
      if ncommit_lines > 1 then
        local commit_out_index = 2

        -- Draw collapsed body
        vim_commit.collapsed_body = commit_multiline_prefix .. commit_collapsed_body

        -- Draw body
        if commit_collapsed and commit_collapsed ~= 0 then
          vim_line_commits[out_line] = vim_commit_index
          vim_out[out_line] = vim_commit.collapsed_body
          out_line = out_line + 1

          while commit_out_index <= ncommit_lines do
            vim_commit_body[commit_out_index - 1] = commit_multiline_prefix .. commit_out[commit_out_index]
            commit_out_index = commit_out_index + 1
          end
        else
          while commit_out_index <= ncommit_lines do
            vim_commit_body[commit_out_index - 1] = commit_multiline_prefix .. commit_out[commit_out_index]

            vim_line_commits[out_line] = vim_commit_index
            vim_out[out_line] = vim_commit_body[commit_out_index - 1]
            out_line = out_line + 1

            commit_out_index = commit_out_index + 1
          end
        end
      end

      -- Draw commit suffix
      local vim_commit_suffix_index = 0
      if should_out_merge_line then
        vim_commit.merge_col = commit_merge_col
        vim_commit.merge_end_col = commit_merge_end_col
        vim_commit_suffix_index = vim_commit_suffix_index + 1
        vim_line_commits[out_line] = vim_commit_index
        vim_out[out_line] = merge_line
        out_line = out_line + 1
        vim_commit_suffix[vim_commit_suffix_index] = merge_line
      end
      if nmissing_parents > 0 then
        vim_commit_suffix_index = vim_commit_suffix_index + 1
        vim_line_commits[out_line] = vim_commit_index
        vim_out[out_line] = missing_parents_line
        out_line = out_line + 1
        vim_commit_suffix[vim_commit_suffix_index] = missing_parents_line
      end
      if should_pad then
        local padding_line = table.concat(branch_out, '', 1, graph_width)
        vim_commit_suffix_index = vim_commit_suffix_index + 1
        vim_line_commits[out_line] = vim_commit_index
        vim_out[out_line] = padding_line
        out_line = out_line + 1
        vim_commit_suffix[vim_commit_suffix_index] = padding_line
      end
      vim_commit.suffix_len = vim_commit_suffix_index

      -- Add commit to list of commits
      vim_commits[commit_index] = vim_commit
      vim_commits_by_hash[commit_hash] = vim_commit_index
    else
      -- Output using stdout

      if enable_porcelain then
        -- Print commit hash
        print(commit_hash)

        -- Print commit visual parents
        print(nvim_parents)
        for _, parent in ipairs(vim_commit_parents) do
          print(parent)
        end

        -- Print commit refs
        print(commit.refs)

        -- Print commit col
        print(commit_col)

        -- Print commit format start
        print(commit_format_col)

        -- Print commit length
        print(ncommit_lines)

        -- Print suffix length
        print((should_out_merge_line and 1 or 0)
          + (nmissing_parents > 0 and 1 or 0)
          + (should_pad and 1 or 0))

        -- Print collapsed format
        if ncommit_lines > 1 then
          io.write(commit_multiline_prefix)
          io.write(commit_collapsed_body)
          io.write('\n')
        end
      end

      -- Print commit subject
      print(commit_subject_line)

      -- Print commit body
      local commit_out_index = 2
      while commit_out_index <= ncommit_lines do
        io.write(commit_multiline_prefix)
        io.write(commit_out[commit_out_index])
        io.write('\n')
        commit_out_index = commit_out_index + 1
      end

      -- Print commit suffix
      if should_out_merge_line then
        print(merge_line)
      end
      if nmissing_parents > 0 then
        print(missing_parents_line)
      end
      if should_pad then
        print(table.concat(branch_out, '', 1, graph_width))
      end
    end
  end

  if enable_vim_out then
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
    default_collapsed,
    graph,
    collapsed_commits)
  -- Init vim output
  local vim_out
  local out_line = 1
  local vim_commits = graph.commits
  local vim_commits_by_hash = graph.commits_by_hash
  local vim_line_commits

  if not enable_nvim then
    vim_out = vim.list()
    vim_line_commits = vim.list()
  else
    vim_out = {}
    vim_line_commits = {}
  end

  -- Find number of commits
  local ncommits = #commits

  -- Rebuild output/line commits
  local commit_index = 1
  while commit_index <= ncommits do
    local vim_commit_index = commit_index - 1
    local commit = vim_commits[commit_index]
    local hash = commit.hash
    local len = commit.len
    local suffix_len = commit.suffix_len

    -- Update line position
    commit.line = out_line

    -- Add subject
    vim_out[out_line] = commit.subject
    vim_line_commits[out_line] = vim_commit_index
    out_line = out_line + 1

    if len > 1 then
      local collapsed = collapsed_commits[hash]

      if collapsed == nil then
        collapsed = default_collapsed
      end

      if collapsed and collapsed ~= 0 then
        -- Add collapsed body
        vim_out[out_line] = commit.collapsed_body
        vim_line_commits[out_line] = vim_commit_index
        out_line = out_line + 1
      else
        -- Add body
        local body_index = 1
        local body = commit.body
        while body_index < len do
          vim_out[out_line] = body[body_index]
          vim_line_commits[out_line] = vim_commit_index
          body_index = body_index + 1
          out_line = out_line + 1
        end
      end
    end

    if suffix_len > 0 then
      -- Add suffix
      local suffix_index = 1
      local suffix = commit.suffix
      while suffix_index <= suffix_len do
        vim_out[out_line] = suffix[suffix_index]
        vim_line_commits[out_line] = vim_commit_index
        suffix_index = suffix_index + 1
        out_line = out_line + 1
      end
    end

    -- Increment
    commit_index = commit_index + 1
  end

  -- Return
  local dict_out = {
    output = vim_out,
    commits = vim_commits,
    commits_by_hash = vim_commits_by_hash,
    line_commits = vim_line_commits,
  }
  if enable_nvim then
    return dict_out
  else
    return vim.dict(dict_out)
  end
end

_G.flog_get_graph = flog_get_graph
_G.flog_update_graph = flog_update_graph
