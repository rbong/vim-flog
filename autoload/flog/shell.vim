vim9script

#
# This file contains functions for working with shell commands.
#

def flog#shell#escape(str: string): string
  return fnameescape(str)
enddef

def flog#shell#escape_list(list: list<string>): list<string>
  return map(copy(list), (_, val) => flog#shell#escape(val))
enddef

def flog#shell#run(cmd: string): list<string>
  const output = systemlist(cmd)
  if !empty(v:shell_error)
    echoerr join(output, "\n")
    throw g:flog_shell_error
  endif
  return output
enddef
