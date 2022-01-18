vim9script

#
# This file contains functions for handling lists.
#

def flog#list#exclude(list: list<any>, filters: list<any>): list<any>
  return filter(copy(list), (_, val) => index(filters, val) < 0)
enddef
