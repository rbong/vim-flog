-- This file contains functions for managing branch highlight groups in Neovim.

local flog_graph = require('flog/graph')

local M = {}

local hl_group_names = {
  "flogBranch1",
  "flogBranch2",
  "flogBranch3",
  "flogBranch4",
  "flogBranch5",
  "flogBranch6",
  "flogBranch7",
  "flogBranch8",
  "flogBranch9",
}

function M.nvim_get_graph_hl_callback(buffer, instance_number)
  local winid = vim.fn.bufwinid(buffer)
  local wincol = vim.fn.wincol()

  -- Read options
  local enable_extended_chars = vim.g.flog_enable_extended_chars and vim.g.flog_enable_extended_chars ~= 0

  -- Read internal state
  local internal_state = flog_graph.get_internal_graph_state(instance_number)
  local line_commits = internal_state.line_commits
  local commits = internal_state.commits
  local hl_cache = internal_state.hl_cache

  -- Initialize memoization
  local line_memos = {}
  local branch_memos = {}
  local merge_memo = {}

  return function (ev)
    -- Update wincol
    if vim.fn.win_getid() == winid then
      wincol = vim.fn.wincol()
    end

    -- Get line/col
    local start_line = vim.fn.line('w0', winid)
    local end_line = vim.fn.line('w$', winid)
    local start_col = vim.fn.virtcol('.', false, winid) - wincol + 2
    if vim.o.number or vim.o.relativenumber then
      start_col = start_col + vim.o.numberwidth
    end
    local end_col = start_col + vim.fn.winwidth(0) - 1

    -- Get start/end branch index from screen position/size
    local start_branch_index = math.floor((start_col - 1) / 2) + 1
    local end_branch_index = math.floor((end_col - 1) / 2) + 1

    -- Get commit at top of screen
    local start_commit_index = line_commits[start_line] + 1

    -- Get initial branch highlight numbers from cache
    local current_hl = {}
    local cache_commit_index = math.floor((start_commit_index - 1) / 100) * 100 + 1
    local commit_hl_cache = hl_cache[cache_commit_index]
    for branch_index = start_branch_index, math.min(#commit_hl_cache, end_branch_index) do
      current_hl[branch_index] = commit_hl_cache[branch_index]
    end

    -- Handle branch highlighting updates between cached commit and top commit
    for commit_index = cache_commit_index + 1, start_commit_index - 1 do
      for branch_index, branch_hl in pairs(commits[commit_index].hl) do
        current_hl[branch_index] = branch_hl
      end
    end

    -- Initialize line-based memoization
    local line_memo = line_memos[start_branch_index]
    if line_memo == nil then
      line_memo = {}
      line_memos[start_branch_index] = line_memo
    end

    local commit_index
    local commit
    for line = start_line, end_line do
      -- Update current commit data
      local new_commit_index = line_commits[line] + 1
      if new_commit_index ~= commit_index then
        commit_index = new_commit_index
        commit = commits[commit_index]
        for branch_index, branch_hl in pairs(commit.hl) do
          current_hl[branch_index] = branch_hl
        end
      end

      if line_memo[line] == nil or line_memo[line] < end_branch_index then
        line_memo[line] = end_branch_index

        -- Initialize branch-based memoization
        local branch_memo = branch_memos[line]
        if branch_memo == nil then
          branch_memo = {}
          branch_memos[line] = branch_memo
        end

        if not enable_extended_chars and line == commit.line then
          -- Set highlight groups for commit subject
          for branch_index = start_branch_index, math.min(commit.format_branch_index, end_branch_index) do
            if branch_index ~= commit.branch_index and branch_memo[branch_index] == nil then
              branch_memo[branch_index] = 1
              local col = vim.fn.virtcol2col(winid, line, 2 * branch_index - 1)
              vim.api.nvim_buf_add_highlight(
                buffer,
                -1,
                hl_group_names[current_hl[branch_index]],
                line - 1,
                col - 1,
                col)
            end
          end
        elseif line < commit.suffix_line then
          -- Set highlight groups for commit body
          for branch_index = start_branch_index, math.min(commit.format_branch_index, end_branch_index) do
            if branch_memo[branch_index] == nil then
              branch_memo[branch_index] = 1
              local col = vim.fn.virtcol2col(winid, line, 2 * branch_index - 1)
              vim.api.nvim_buf_add_highlight(
                buffer,
                -1,
                hl_group_names[current_hl[branch_index]],
                line - 1,
                col - 1,
                col)
            end
          end
        elseif commit.has_merge and line == commit.suffix_line then
          -- Set highlight groups for the merge line

          -- Set highlight groups before merge
          for branch_index = start_branch_index, commit.merge_branch_index - 1 do
            if branch_memo[branch_index] == nil then
              branch_memo[branch_index] = 1
              local col = vim.fn.virtcol2col(winid, line, 2 * branch_index - 1)
              vim.api.nvim_buf_add_highlight(
                buffer,
                -1,
                hl_group_names[current_hl[branch_index]],
                line - 1,
                col - 1,
                col)
            end
          end

          if merge_memo[line] == nil then
            merge_memo[line] = 1
            local merge_col = vim.fn.virtcol2col(winid, line, 2 * commit.merge_branch_index - 1)
            local end_merge_col = vim.fn.virtcol2col(winid, line, 2 * commit.merge_end_branch_index - 1)

            -- Set highlight groups for merge
            if commit.moved_parent then
              local commit_col = vim.fn.virtcol2col(winid, line, 2 * commit.branch_index - 1)

              vim.api.nvim_buf_add_highlight(
                buffer,
                -1,
                hl_group_names[current_hl[commit.branch_index] or commit_hl_cache[commit.branch_index]],
                line - 1,
                merge_col - 1,
                commit_col)

              vim.api.nvim_buf_add_highlight(
                buffer,
                -1,
                hl_group_names[current_hl[commit.merge_end_branch_index] or commit_hl_cache[commit.merge_end_branch_index]],
                line - 1,
                commit_col,
                end_merge_col)
            else
              vim.api.nvim_buf_add_highlight(
                buffer,
                -1,
                hl_group_names[current_hl[commit.branch_index] or commit_hl_cache[commit.branch_index]],
                line - 1,
                merge_col - 1,
                end_merge_col)
            end

            -- Set highlight groups for branch crossovers
            for branch_index, _ in pairs(commit.merge_crossovers) do
              local col = vim.fn.virtcol2col(winid, line, 2 * branch_index - 1)
              local hl = current_hl[branch_index]
              if hl ~= nil then
                vim.api.nvim_buf_add_highlight(
                  buffer,
                  -1,
                  hl_group_names[hl],
                  line - 1,
                  col - 1,
                  col)
              end
            end
          end

          -- Set highlight groups for post-merge
          for branch_index = math.max(commit.merge_end_branch_index, start_branch_index), math.min(commit.suffix_graph_width, end_branch_index) do
            if branch_memo[branch_index] == nil then
              branch_memo[branch_index] = 1
              local col = vim.fn.virtcol2col(winid, line, 2 * branch_index - 1)
              vim.api.nvim_buf_add_highlight(
                buffer,
                -1,
                hl_group_names[current_hl[branch_index]],
                line - 1,
                col - 1,
                col)
            end
          end
        else
          -- Set highlight groups for the rest of the commit suffix
          for branch_index = start_branch_index, math.min(commit.suffix_graph_width, end_branch_index) do
            if branch_memo[branch_index] == nil then
              branch_memo[branch_index] = 1
              local col = vim.fn.virtcol2col(winid, line, 2 * branch_index - 1)
              if col > 0 then
                vim.api.nvim_buf_add_highlight(
                  buffer,
                  -1,
                  hl_group_names[current_hl[branch_index]],
                  line - 1,
                  col - 1,
                  col)
              end
            end
          end
        end
      end
    end
  end
end

return M
