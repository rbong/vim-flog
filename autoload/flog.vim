vim9script

#
# This file contains public Flog API functions.
#

import autoload 'flog/exec.vim'
import autoload 'flog/win.vim'

import autoload 'flog/floggraph/buf.vim'
import autoload 'flog/floggraph/side_win.vim'

export def ExecRaw(cmd: string, keep_focus: bool = 0, should_update: bool = 0, is_tmp: bool = 0): string
  if !buf.IsFlogBuf()
    exec cmd
    return cmd
  endif

  const graph_win = win.Save()
  side_win.Open(cmd, keep_focus, is_tmp)

  if should_update
    if win.Is(graph_win)
      buf.Update()
    else
      buf.InitUpdateHook(win.GetSavedBufnr(graph_win))
    endif
  endif

  return cmd
enddef

export def Exec(cmd: string, keep_focus: bool = 0, should_update: bool = 0, is_tmp: bool = 0): string
  buf.AssertFlogBuf()

  const formatted_cmd = exec.Format(cmd)
  if empty(formatted_cmd)
    return ''
  endif

  return ExecRaw(formatted_cmd, keep_focus, should_update, is_tmp)
enddef

export def ExecTmp(cmd: string, keep_focus: bool = 0, should_update: bool = 0): string
  return Exec(cmd, keep_focus, should_update, true)
enddef

# Deprecations

legacy function flog#run_raw_command(...) abort
  call flog#deprecate#Function('flog#run_raw_command', 'flog#ExecRaw')
endfunction

legacy function flog#run_command(...) abort
  call flog#deprecate#Function('flog#run_command', 'flog#Exec')
endfunction

legacy function flog#run_tmp_command(...) abort
  call flog#deprecate#Function('flog#run_tmp_command', 'flog#ExecTmp')
endfunction
