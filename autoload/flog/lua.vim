vim9script

#
# This file contains functions which allow Flog to communicate with Lua.
#

import autoload 'flog/shell.vim'

export def ShouldUseInternal(): bool
  const use_lua = get(g:, 'flog_use_internal_lua', false)

  if use_lua && !has('lua')
    echoerr 'flog: warning: internal Lua is enabled but unavailable'
    return false
  endif

  return use_lua
enddef

g:flog_did_check_lua_internal_version = false

export def CheckInternalVersion(): bool
  if g:flog_check_lua_version && !g:flog_did_check_lua_internal_version
    g:flog_did_check_lua_internal_version = true

    if luaeval('_VERSION') !~ '\c^lua 5\.1\(\.\|$\)'
      echoerr 'flog: warning: only Lua 5.1 and LuaJIT 2.1 are supported'
    elseif empty(luaeval('jit and jit.version'))
      echoerr 'flog: warning: for speed improvements, please compile Vim with LuaJIT 2.1'
    endif

    return true
  endif

  return false
enddef

g:flog_did_check_lua_bin_version = false

export def CheckBinVersion(bin: string): bool
  if g:flog_check_lua_version && !g:flog_did_check_lua_bin_version
    g:flog_did_check_lua_bin_version = true

    const out = shell.Run(bin .. ' -v')[0]

    if out =~ '\c^lua 5\.1\(\.\|$\)'
      echoerr 'flog: warning: for speed improvements, please install LuaJIT 2.1'
    elseif out !~ '\c^luajit 2\.1\(\.\|$\)'
      echoerr 'flog: warning: only Lua 5.1 and LuaJIT 2.1 are supported'
    endif

    return true
  endif

  return false
enddef

export def GetBin(): string
  var bin = ''

  if exists('g:flog_lua_bin')
    bin = shellescape(g:flog_lua_bin)
  elseif executable('luajit')
    bin = 'luajit'
  elseif executable('lua')
    bin = 'lua'
  else
    echoerr 'flog: please install LuaJIT 2.1 it or set it with g:flog_lua_bin'
    throw g:flog_lua_not_found
  endif

  CheckBinVersion(bin)

  return bin
enddef

export def GetLibPath(lib: string): string
  return g:flog_lua_dir .. '/flog/' .. lib
enddef

export def SetLuaPath(): list<any>
  const had_lua_path = exists('$LUA_PATH')
  const original_lua_path = $LUA_PATH

  $LUA_PATH = escape(g:flog_lua_dir, '\;?') .. '/?.lua'

  return [had_lua_path, original_lua_path]
enddef

export def ResetLuaPath(lua_path_info: list<any>)
  const [had_lua_path, original_lua_path] = lua_path_info

  if !had_lua_path
    unlet $LUA_PATH
  else
    $LUA_PATH = original_lua_path
  endif
enddef
