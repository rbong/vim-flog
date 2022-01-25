vim9script

#
# This file contains public Flog API functions.
#

def flog#exec_raw(cmd: string, keep_focus: bool, should_update: bool, is_tmp: bool): string
  if !flog#floggraph#buf#is_flog_buf()
    exec cmd
    return cmd
  endif

  const bufnr = bufnr()
  const graph_win_id = win_getid()
  flog#floggraph#side_win#open(cmd, keep_focus, is_tmp)

  if should_update
    if win_getid() == graph_win_id
      flog#floggraph#buf#update()
    else
      flog#floggraph#buf#init_update_hook(bufnr)
    endif
  endif

  return cmd
enddef

def flog#run_raw_command(...args: list<any>)
  flog#deprecate#function('flog#run_raw_command', 'flog#exec_raw')
enddef

def flog#exec(cmd: string, keep_focus: bool, should_update: bool, is_tmp: bool): string
  flog#floggraph#buf#assert_flog_buf()

  const formatted_cmd = flog#exec#format(cmd)
  if empty(formatted_cmd)
    return ''
  endif

  return flog#exec_raw(formatted_cmd, keep_focus, should_update, is_tmp)
enddef

def flog#run_command(...args: list<any>)
  flog#deprecate#function('flog#run_command', 'flog#exec')
enddef

def flog#exec_tmp(cmd: string, keep_focus: bool, should_update: bool): string
  return flog#exec(cmd, keep_focus, should_update, true)
enddef

def flog#run_tmp_command(...args: list<any>)
  flog#deprecate#function('flog#run_tmp_command', 'flog#exec_tmp')
enddef
