vim9script

#
# This file contains functions for handling args to commands.
#

import autoload 'flog/fugitive.vim'

export def SplitArg(arg: string): list<string>
  const match = matchlist(arg, '\v(.{-}(\=|$))(.*)')
  return [match[1], match[3]]
enddef

export def ParseArg(arg: string): string
  return SplitArg(arg)[1]
enddef

export def UnescapeArg(arg: string): string
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

export def SplitGitLimitArg(limit: string): list<string>
  const [match, start, end] = matchstrpos(limit, '^.\{1,}:\zs')
  if start < 0
    return [limit, '']
  endif
  return [limit[ : start - 1], limit[start : ]]
enddef

export def ParseGitLimitArg(workdir: string, arg: string): string
  const arg_opt = ParseArg(arg)
  var [range, path] = SplitGitLimitArg(arg_opt)

  if empty(path)
    return arg_opt
  endif

  return range .. fugitive.GetRelativePath(workdir, expand(path))
enddef

export def ParseGitPathArg(workdir: string, arg: string): string
  const arg_opt = ParseArg(arg)
  return fugitive.GetRelativePath(workdir, expand(arg_opt))
enddef

export def FilterCompletions(arg_lead: string, completions: list<string>): list<string>
  const lead = '^' .. escape(arg_lead, '\\')
  return filter(copy(completions), (_, val) => val =~ lead)
enddef

export def EscapeCompletions(lead: string, completions: list<string>): list<string>
  return map(copy(completions), (_, val) => lead .. substitute(val, ' ', '\\ ', 'g'))
enddef
