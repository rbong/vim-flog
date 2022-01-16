vim9script

#
# This file contains functions for handling args to commands.
#

def flog#utils#args#split_arg(arg: string): list<string>
  const match = matchlist(arg, '\v(.{-}(\=|$))(.*)')
  return [match[1], match[3]]
enddef

def flog#utils#args#parse_arg(arg: string): string
  return flog#utils#args#split_arg(arg)[1]
enddef

def flog#utils#args#unescape_arg(arg: string): string
  var unescaped = ''
  var is_escaped = false

  for char in split(arg, '\zs')
    if char == '\' && !is_escaped
      is_escaped = true
    else
      unescaped ..= char
      is_escaped = false
    endif
  endfor

  return unescaped
enddef

def flog#utils#args#split_git_limit_arg(limit: string): list<string>
  const [match, start, end] = matchstrpos(limit, '^.\{1,}:\zs')
  if start < 0
    return [limit, '']
  endif
  return [limit[ : start - 1], limit[start : ]]
enddef

def flog#utils#args#parse_git_limit_arg(workdir: string, arg: string): string
  const arg_opt = flog#utils#args#parse_arg(arg)
  var [range, path] = flog#utils#args#split_git_limit_arg(arg_opt)

  if empty(path)
    return arg_opt
  endif

  return range .. fnameescape(flog#fugitive#get_relative_path(workdir, path))
enddef

def flog#utils#args#parse_git_path_arg(workdir: string, arg: string): string
  const arg_opt = flog#utils#args#parse_arg(arg)
  const path = flog#fugitive#get_relative_path(workdir, arg_opt)
  return fnameescape(path)
enddef

def flog#utils#args#filter_completions(arg_lead: string, completions: list<string>): list<string>
  const lead = '^' .. escape(arg_lead, '\\')
  return filter(copy(completions), (_, val) => val =~ lead)
enddef

def flog#utils#args#escape_completions(lead: string, completions: list<string>): list<string>
  return map(copy(completions), (_, val) => lead .. substitute(val, ' ', '\\ ', 'g'))
enddef
