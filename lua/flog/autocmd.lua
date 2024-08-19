-- This file contains functions for speeding up speed sensitive autocommands in Neovim.

local flog_hl = require("flog/highlight")

local M = {}

function M.nvim_create_graph_autocmds(buffer, instance_number, enable_graph)
  -- Create group and clear previous autocmds
  local group = vim.api.nvim_create_augroup("Floggraph", { clear = true })

  -- Clear highlighting
  vim.api.nvim_buf_clear_namespace(buffer, -1, 0, -1)

  if enable_graph and enable_graph ~= 0 then
    -- Initialize highlighting
    local hl_cb = flog_hl.nvim_get_graph_hl_callback(buffer, instance_number)
    hl_cb({})

    -- Create autocmds
    return {
      vim.api.nvim_create_autocmd(
        { "CursorMoved", "WinResized" },
        {
          buffer = buffer,
          callback = hl_cb,
          group = group,
        }
      ),
    }
  end

  return {}
end

return M
