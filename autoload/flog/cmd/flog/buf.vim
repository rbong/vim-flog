vim9script

#
# This file contains functions for creating and updating the ":Flog" buffer.
#

def flog#cmd#flog#buf#open(state: dict<any>): number
  execute state.opts.open_cmd

  flog#state#set_buf_state(state)

  var bufnr = bufnr()
  flog#state#set_graph_bufnr(state, bufnr)

  flog#fugitive#trigger_detection(flog#state#get_fugitive_workdir(state))

  setlocal buftype=nofile nobuflisted nomodifiable nowrap
  set ft=floggraph

  return bufnr
enddef

def flog#cmd#flog#buf#set_content(content: list<string>): list<string>
  set modifiable
  :1,$ delete
  setline(1, content)
  set nomodifiable

  return content
enddef
