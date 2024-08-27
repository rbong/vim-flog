-- This file contains functions for watching Git directories for changes in Neovim.

local uv = vim.uv or vim.loop

local git_dirs = {}
local bufs = {}

local M = {}

function M.nvim_start_watching(dir)
  local handle = uv.new_fs_event()
  local timer = nil

  handle:start(
    dir,
    {},
    vim.schedule_wrap(
      function (err, fname, status)
        if timer then
          timer:stop()
          timer:close()
          timer = nil
        end
        timer = vim.defer_fn(
          function ()
            if git_dirs[dir] == nil then
              return
            end

            local saved_win = vim.fn['flog#win#Save']()

            local bufs = git_dirs[dir].bufs
            for buf, is_active in pairs(bufs) do
              if is_active then
                local winid = vim.fn.win_findbuf(buf)[1]
                if winid ~= nil then
                  vim.fn.win_gotoid(winid)
                  if vim.fn['flog#floggraph#opts#ShouldAutoUpdate']() then
                    vim.fn['flog#floggraph#buf#Update']()
                  end
                end
              end
            end

            if not git_dirs[dir].bufs[vim.fn['flog#win#GetSavedBufnr'](saved_win)] then
              vim.fn['flog#win#Restore'](saved_win)
            end
          end,
          -- Defer function for 100ms to prevent rapid updates
          100
        )
      end
    )
  )

  return handle
end

function M.nvim_stop_watching(dir)
  if git_dirs[dir] == nil then
    return false
  end

  local handle = git_dirs[dir].handle
  if handle == nil then
    return false
  end

  git_dirs[dir].handle = nil
  handle:stop()

  return true
end

function M.nvim_add_buf(buf, dir)
  if bufs[buf] ~= nil then
    M.nvim_remove_buf(buf)
  end

  if git_dirs[dir] == nil then
    git_dirs[dir] = {
      bufs = {},
      nbufs = 0,
      handle = M.nvim_start_watching(dir),
    }
  elseif git_dirs[dir].bufs[buf] then
    return false
  end

  local nbufs = git_dirs[dir].nbufs + 1
  git_dirs[dir].nbufs = nbufs
  git_dirs[dir].bufs[buf] = true
  bufs[buf] = dir

  return true
end

function M.nvim_remove_buf(buf)
  local dir = bufs[buf]
  if dir == nil then
    return false
  end

  bufs[buf] = nil

  local nbufs = git_dirs[dir].nbufs - 1
  if nbufs == 0 then
    M.nvim_stop_watching(dir)
    git_dirs[dir] = nil
  else
    git_dirs[dir].nbufs = nbufs
    git_dirs[dir].bufs[buf] = nil
  end

  return true
end

function M.nvim_register_floggraph_buf()
  vim.fn['flog#floggraph#buf#AssertFlogBuf']()
  if (vim.fn['flog#fugitive#IsGitBuf']() or 0) == 0 then
    return false
  end

  local buf = vim.fn.bufnr()
  local git_dir = vim.fn['flog#fugitive#GetGitDir']()
  return M.nvim_add_buf(buf, git_dir)
end

function M.nvim_unregister_floggraph_buf()
  vim.fn['flog#floggraph#buf#AssertFlogBuf']()
  if (vim.fn['flog#fugitive#IsGitBuf']() or 0) == 0 then
    return false
  end

  local buf = vim.fn.bufnr()
  return M.nvim_remove_buf(buf)
end

return M
