-- This file contains functions for watching Git directories for changes in Neovim.

local uv = vim.uv or vim.loop

local git_dirs = {}
local bufs = {}

local M = {}

function M.get_watch_paths(dir)
  local dirs = { dir, dir .. '/refs' }

  local git_ref_subdirs = { 'bisect', 'remotes', 'heads', 'tags' }
  for _, ref_subdir in ipairs(git_ref_subdirs) do
    dirs[#dirs + 1] = dir .. '/refs/' .. ref_subdir
  end

  local remotes_dir = dir .. '/refs/remotes'
  for path, type in vim.fs.dir(remotes_dir, { depth = 1 }) do
    if type == 'directory' then
      dirs[#dirs + 1] = remotes_dir .. '/' .. path
    end
  end

  return dirs
end

function M.nvim_start_watching(dir)
  local timer = nil
  local cb = vim.schedule_wrap(
    function (err, fname, status)
      if timer then
        pcall(function ()
          timer:stop()
          timer:close()
        end)
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

          if not git_dirs[dir].bufs[saved_win.bufnr] then
            vim.fn['flog#win#Restore'](saved_win)
          end
        end,
        -- Defer function for 100ms to prevent rapid updates
        100
      )
    end
  )

  local handles = {}
  for index, dir in ipairs(M.get_watch_paths(dir)) do
    handles[index] = uv.new_fs_event()
    handles[index]:start(dir, {}, cb)
  end

  return handles
end

function M.nvim_stop_watching(dir)
  if git_dirs[dir] == nil then
    return false
  end

  for _, handle in ipairs(git_dirs[dir].handles) do
    handle:stop()
  end
  git_dirs[dir].handles = nil

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
      handles = M.nvim_start_watching(dir),
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
  if (vim.fn['flog#backend#IsGitBuf']() or 0) == 0 then
    return false
  end

  local buf = vim.fn.bufnr()
  local git_dir = vim.fn['flog#backend#GetGitDir']()
  return M.nvim_add_buf(buf, git_dir)
end

function M.nvim_unregister_floggraph_buf(buf)
  return M.nvim_remove_buf(buf)
end

return M
