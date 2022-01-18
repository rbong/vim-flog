vim9script

#
# This file contains functions for handling windows.
#

def flog#win#get_all_ids(): list<number>
  var windows = []
  for tab in gettabinfo()
    windows += tab.windows
  endfor
  return windows
enddef
