"
" This file contains functions which allow Flog to communicate with Lua.
"

function! flog#lua#ShouldUseInternal() abort
  let l:use_lua = get(g:, 'flog_use_internal_lua', v:false)

  if l:use_lua && !has('lua')
    call flog#print#err('flog: warning: internal Lua is enabled but unavailable')
    return v:false
  endif

  return l:use_lua
endfunction

let g:flog_did_check_lua_internal_version = v:false

function! flog#lua#CheckInternalVersion() abort
  if g:flog_check_lua_version && !g:flog_did_check_lua_internal_version
    let g:flog_did_check_lua_internal_version = v:true

    if luaeval('_VERSION') !~# '\c^lua 5\.1\(\.\|$\)'
      call flog#print#err('flog: warning: only Lua 5.1 and LuaJIT 2.1 are supported')
    elseif empty(luaeval('jit and jit.version'))
      call flog#print#err('flog: warning: for speed improvements, please compile Vim with LuaJIT 2.1')
    endif

    return v:true
  endif

  return v:false
endfunction

let g:flog_did_check_lua_bin_version = v:false

function! flog#lua#CheckBinVersion(bin) abort
  if g:flog_check_lua_version && !g:flog_did_check_lua_bin_version
    let g:flog_did_check_lua_bin_version = v:true

    let l:out = flog#shell#Run(a:bin . ' -v')[0]

    if l:out =~# '\c^lua 5\.1\(\.\|$\)'
      call flog#print#err('flog: warning: for speed improvements, please install LuaJIT 2.1')
    elseif l:out !~# '\c^luajit 2\.1\(\.\|$\)'
      call flog#print#err('flog: warning: only Lua 5.1 and LuaJIT 2.1 are supported')
    endif

    return v:true
  endif

  return v:false
endfunction

function! flog#lua#GetBin() abort
  let l:bin = ''

  if exists('g:flog_lua_bin')
    let l:bin = shellescape(g:flog_lua_bin)
  elseif executable('luajit')
    let l:bin = 'luajit'
  elseif executable('lua')
    let l:bin = 'lua'
  else
    call flog#print#err('flog: please install LuaJIT 2.1 it or set it with g:flog_lua_bin')
    throw g:flog_lua_not_found
  endif

  call flog#lua#CheckBinVersion(l:bin)

  return l:bin
endfunction

function! flog#lua#GetLibPath(lib) abort
  return g:flog_lua_dir . '/flog/' . a:lib
endfunction

function! flog#lua#SetLuaPath() abort
  let l:had_lua_path = exists('$LUA_PATH')
  let l:original_lua_path = $LUA_PATH

  let $LUA_PATH = escape(g:flog_lua_dir, '\;?') . '/?.lua'

  return [l:had_lua_path, l:original_lua_path]
endfunction

function! flog#lua#ResetLuaPath(lua_path_info) abort
  let [l:had_lua_path, l:original_lua_path] = a:lua_path_info

  if !l:had_lua_path
    unlet $LUA_PATH
  else
    let $LUA_PATH = l:original_lua_path
  endif
endfunction
