vim9script

#
# This file contains functions for working with global options.
#

export def GetSortType(name: string): dict<any>
  for sort_type in g:flog_sort_types
    if sort_type.name == name
      return sort_type
    endif
  endfor
  return {}
enddef
