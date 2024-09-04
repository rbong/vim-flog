--
-- This file contains Lua wrapper functions for the Flog public API.
--

local M = {}

function M.version()
  return vim.fn["flog#Version"]()
end

function M.exec(cmd, blur, static, tmp)
  return vim.fn["flog#Exec"](cmd, blur or false, static or false, tmp or false)
end

function M.exec_tmp(cmd, blur, static)
  return vim.fn["flog#ExecTmp"](cmd, blur or false, static or false)
end

function M.format(cmd)
  return vim.fn["flog#Format"](cmd)
end

return M
