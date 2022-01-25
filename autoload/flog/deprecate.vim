vim9script

#
# This file contains functions for deprecation.
#

g:flog_shown_deprecation_warnings = {}

def flog#deprecate#show_warning(old_usage: string, new_usage: string)
  echoerr printf('Deprecated: %s', old_usage)
  echoerr printf('New usage: %s', new_usage)
  g:flog_shown_deprecation_warnings[old_usage] = true
enddef

def flog#deprecate#did_show_warning(old_usage: string): bool
  return has_key(g:flog_shown_deprecation_warnings, old_usage)
enddef

def flog#deprecate#default_mapping(old_mapping: string, new_mapping: string)
  flog#deprecate#show_warning(old_mapping, new_mapping)
enddef

def flog#deprecate#setting(old_setting: string, new_setting: string, new_value = '...')
  if exists(old_setting) && !flog#deprecate#did_show_warning(old_setting)
    const new_usage = printf('let %s = %s', new_setting, new_value)
    flog#deprecate#show_warning(old_setting, new_usage)
  endif
enddef

def flog#deprecate#function(old_func: string, new_func: string, new_args = '...')
  const old_usage = printf('%s()', old_func)
  const new_usage = printf('call %s(%s)', new_func, new_args)
  flog#deprecate#show_warning(old_usage, new_usage)
enddef
