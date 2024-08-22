-- This file contains functions for speeding up speed sensitive autocommands in Neovim.

local flog_graph = require("flog/graph")
local flog_hl = require("flog/highlight")

local M = {}

function M.nvim_init_hl_autocmd(group, buffer, instance_number)
  local winid = vim.fn.bufwinid(buffer)

  local hl_cb = flog_hl.nvim_get_graph_hl_callback(buffer, winid, instance_number)
  hl_cb({})

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
  -- Create group and clear previous autocmds
  local group = vim.api.nvim_create_augroup("Floggraph", { clear = true })

  -- Clear highlighting
  vim.api.nvim_buf_clear_namespace(buffer, -1, 0, -1)

  if enable_graph and enable_graph ~= 0 then
    -- Create autocmds

    M.nvim_init_hl_autocmd(group, buffer, instance_number)

    vim.api.nvim_create_autocmd(
      { "BufWipeout" },
      {
        buffer = buffer,
        callback = function (ev)
          flog_graph.clear_internal_graph_state(instance_number)
        end,
        group = group,
      }
    )

    vim.api.nvim_create_autocmd(
      { "WinEnter" },
      {
        buffer = buffer,
        callback = function (ev)
          if vim.fn.bufnr() == buffer then
            M.nvim_init_hl_autocmd(group, buffer, instance_number)
          end
        end,
        group = group,
      }
    )

    return group
  end

  return {}
end

return M
