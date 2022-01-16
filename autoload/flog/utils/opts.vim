vim9script

#
# This file contains functions for working with options.
#

def flog#utils#opts#get_sort_type(name: string): dict<any>
  for sort_type in g:flog_sort_types
    if sort_type.name == name
      return sort_type
    endif
  endfor
  throw g:flog_sort_type_not_found
  return {}
enddef
