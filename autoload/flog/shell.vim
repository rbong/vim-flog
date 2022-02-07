vim9script

#
# This file contains functions for working with shell commands.
#

export def Escape(str: string): string
  return fnameescape(str)
enddef

export def EscapeList(list: list<string>): list<string>
  return map(copy(list), (_, val) => Escape(val))
enddef

export def Run(cmd: string): list<string>
  const output = systemlist(cmd)
  if !empty(v:shell_error)
    echoerr join(output, "\n")
    throw g:flog_shell_error
  endif
  return output
enddef
