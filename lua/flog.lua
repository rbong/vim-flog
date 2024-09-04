--
-- This file contains Lua wrapper functions for the Flog public API.
--

local M = {}

function M.version()
  return vim.fn["flog#Version"]()
end

function M.exec(cmd, opts)
  return vim.fn["flog#Exec"](cmd, opts or {})
end

function M.exec_tmp(cmd, opts)
  return vim.fn["flog#ExecTmp"](cmd, opts or {})
end

function M.format(cmd)
  return vim.fn["flog#Format"](cmd)
end

return M
