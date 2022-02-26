vim9script

#
# This file contains functions for working with global options.
#

export def GetOrderType(name: string): dict<any>
  for order_type in g:flog_order_types
    if order_type.name == name
      return order_type
    endif
  endfor
  return {}
enddef
