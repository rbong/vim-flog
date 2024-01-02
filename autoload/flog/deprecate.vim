"
" This file contains functions for deprecation.
"

let g:flog_shown_deprecation_warnings = {}

function! flog#deprecate#ShowWarning(old_usage, new_usage) abort
  call flog#print#err('deprecated: %s', a:old_usage)
  call flog#print#err('new usage: %s', a:new_usage)
  let g:flog_shown_deprecation_warnings[a:old_usage] = v:true
endfunction

function! flog#deprecate#DidShowWarning(old_usage) abort
  return has_key(g:flog_shown_deprecation_warnings, a:old_usage)
endfunction

function! flog#deprecate#DefaultMapping(old_mapping, new_mapping) abort
  call flog#deprecate#ShowWarning(a:old_mapping, a:new_mapping)
endfunction

function! flog#deprecate#Setting(old_setting, new_setting, new_value = '...') abort
  if exists(a:old_setting) && !flog#deprecate#DidShowWarning(a:old_setting)
    let l:new_usage = printf('let %s = %s', a:new_setting, a:new_value)
    call flog#deprecate#ShowWarning(a:old_setting, l:new_usage)
  endif
endfunction

function! flog#deprecate#Function(old_func, new_func, new_args = '...') abort
  let l:old_usage = printf('%s()', a:old_func)
  let l:new_usage = printf('call %s(%s)', a:new_func, a:new_args)
  call flog#deprecate#ShowWarning(l:old_usage, l:new_usage)
endfunction

function! flog#deprecate#Command(old_cmd, new_usage) abort
  call flog#deprecate#ShowWarning(a:old_cmd, a:new_usage)
endfunction

function! flog#deprecate#Autocmd(old_autocmd, new_autocmd, new_args = '...') abort
  if !exists(printf('#User#%s', a:old_autocmd))
    return
  endif

  let l:old_usage = printf('autocmd User %s', a:old_autocmd)
  if flog#deprecate#DidShowWarning(l:old_usage)
    return
  endif

  let l:new_usage = printf('autocmd User %s %s', a:new_autocmd, a:new_args)
  call flog#deprecate#ShowWarning(l:old_usage, l:new_usage)
endfunction
