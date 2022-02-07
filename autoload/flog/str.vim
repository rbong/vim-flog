vim9script

#
# This file contains functions for working with strings.
#

export def Ellipsize(str: string, max_len: number = 15): string
  if len(str) > max_len
    return str[ : max_len - 4] .. '...'
  endif

  return str
enddef
