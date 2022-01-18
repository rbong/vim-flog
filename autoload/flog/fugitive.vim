vim9script

#
# This file contains functions for working with fugitive.
#

def flog#fugitive#is_fugitive_buf(): bool
  try
    fugitive#repo()
  catch /not a Git repository/
    return v:false
  endtry
  return v:true
enddef

def flog#fugitive#get_relative_path(workdir: string, path: string): string
  var full_path = fnamemodify(path, ':p')
  if stridx(full_path, workdir) == 0
    return full_path[len(workdir) + 1 : ]
  endif
  return path
enddef

def flog#fugitive#get_repo(): dict<any>
  return fugitive#repo()
enddef

def flog#fugitive#get_workdir(): string
  return flog#fugitive#get_repo().tree()
enddef

def flog#fugitive#get_git_dir(): string
  return flog#fugitive#get_repo().dir()
enddef

def flog#fugitive#get_git_command(): string
  return FugitiveShellCommand()
enddef

def flog#fugitive#trigger_detection(workdir: string): string
  FugitiveDetect(workdir)
  return workdir
enddef

def flog#fugitive#complete(arg_lead: string, cmd_line: string, cursor_pos: number): list<string>
  return fugitive#Complete(arg_lead, cmd_line, cursor_pos)
enddef
