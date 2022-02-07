vim9script

#
# This file contains functions for deprecation.
#

g:flog_shown_deprecation_warnings = {}

export def ShowWarning(old_usage: string, new_usage: string)
  echoerr printf('Deprecated: %s', old_usage)
  echoerr printf('New usage: %s', new_usage)
  g:flog_shown_deprecation_warnings[old_usage] = true
enddef

export def DidShowWarning(old_usage: string): bool
  return has_key(g:flog_shown_deprecation_warnings, old_usage)
enddef

export def DefaultMapping(old_mapping: string, new_mapping: string)
  ShowWarning(old_mapping, new_mapping)
enddef

export def Setting(old_setting: string, new_setting: string, new_value = '...')
  if exists(old_setting) && !DidShowWarning(old_setting)
    const new_usage = printf('let %s = %s', new_setting, new_value)
    ShowWarning(old_setting, new_usage)
  endif
enddef

export def Function(old_func: string, new_func: string, new_args = '...')
  const old_usage = printf('%s()', old_func)
  const new_usage = printf('call %s(%s)', new_func, new_args)
  ShowWarning(old_usage, new_usage)
enddef

export def Command(old_cmd: string, new_usage: string)
  ShowWarning(old_cmd, new_usage)
enddef

export def Autocmd(old_autocmd: string, new_autocmd: string, new_args = '...')
  if !exists(printf('#User#%s', old_autocmd))
    return
  endif

  const old_usage = printf('autocmd User %s', old_autocmd)
  if DidShowWarning(old_usage)
    return
  endif

  const new_usage = printf('autocmd User %s %s', new_autocmd, new_args)
  ShowWarning(old_usage, new_usage)
enddef
