vim9script

#
# This file contains public Flog API functions.
#

export def ExecRaw(cmd: string, keep_focus: bool, should_update: bool, is_tmp: bool): string
  if !flog#floggraph#buf#IsFlogBuf()
    exec cmd
    return cmd
  endif

  const graph_win = flog#win#Save()
  flog#floggraph#side_win#Open(cmd, keep_focus, is_tmp)

  if should_update
    if flog#win#Is(graph_win)
      flog#floggraph#buf#Update()
    else
      flog#floggraph#buf#InitUpdateHook(flog#win#GetSavedBufnr(graph_win))
    endif
  endif

  return cmd
enddef

export def RunRawCommand(...args: list<any>)
  flog#deprecate#Function('flog#run_raw_command', 'flog#ExecRaw')
enddef

export def Exec(cmd: string, keep_focus: bool, should_update: bool, is_tmp: bool): string
  flog#floggraph#buf#AssertFlogBuf()

  const formatted_cmd = flog#exec#Format(cmd)
  if empty(formatted_cmd)
    return ''
  endif

  return ExecRaw(formatted_cmd, keep_focus, should_update, is_tmp)
enddef

export def RunCommand(...args: list<any>)
  flog#deprecate#Function('flog#run_command', 'flog#Exec')
enddef

export def ExecTmp(cmd: string, keep_focus: bool, should_update: bool): string
  return Exec(cmd, keep_focus, should_update, true)
enddef

export def RunTmpCommand(...args: list<any>)
  flog#deprecate#Function('flog#run_tmp_command', 'flog#ExecTmp')
enddef
