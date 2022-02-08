vim9script

#
# This file contains utils only for use in tests.
#

export def Assert(cmd: string)
  if !eval(cmd)
    echoerr cmd
  endif
enddef
