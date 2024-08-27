-- This file contains functions for speeding up speed sensitive autocommands in Neovim.

local flog_graph = require("flog/graph")
local flog_hl = require("flog/highlight")
local flog_watch = require("flog/watch")

local M = {}

function M.nvim_init_hl_autocmd(group, buffer, winid, get_hl_cb)
  local hl_cb = get_hl_cb(winid)
  hl_cb({
    buf = buffer,
    file = winid,
    match = winid,
  })

  return vim.api.nvim_create_autocmd(
    { "WinScrolled", "WinResized" },
    {
      callback = hl_cb,
      group = group,
      pattern = tostring(winid),
    }
  )
end

function M.nvim_create_graph_autocmds(buffer, instance_number, enable_graph)
  -- Resolve Vim values
  enable_graph = enable_graph and enable_graph ~= 0
  local enable_dynamic_branch_hl = (
    vim.g.flog_enable_dynamic_branch_hl
    and vim.g.flog_enable_dynamic_branch_hl ~= 0)

  local winid = vim.fn.bufwinid(buffer)
  local has_hl = { [winid] = true }

  -- Create group and clear previous autocmds
  local group = vim.api.nvim_create_augroup("Floggraph" .. tostring(instance_number), { clear = true })

  local should_add_hl_autocmds = enable_graph and enable_dynamic_branch_hl
  if should_add_hl_autocmds then
    -- Create highlight autocmds

    local get_hl_cb = flog_hl.nvim_get_graph_hl_callback(buffer, instance_number)
    M.nvim_init_hl_autocmd(group, buffer, winid, get_hl_cb)

    vim.api.nvim_create_autocmd(
      { "WinEnter" },
      {
        buffer = buffer,
        callback = function (ev)
          winid = vim.fn.win_getid()
          if not has_hl[winid] and vim.fn.bufnr() == buffer then
            has_hl[winid] = true
            M.nvim_init_hl_autocmd(group, buffer, winid, get_hl_cb)
          end
        end,
        group = group,
      }
    )
  end

  -- Create BufWipeout autocmd
  vim.api.nvim_create_autocmd(
    { "BufWipeout" },
    {
      buffer = buffer,
      callback = function (ev)
        if should_add_hl_autocmds then
          flog_graph.clear_internal_graph_state(instance_number)
        end
        flog_watch.nvim_unregister_floggraph_buf(buffer)
      end,
      group = group,
    }
  )

  return group
end

return M
