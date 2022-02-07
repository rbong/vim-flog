vim9script

#
# This file contains functions for working with Fugitive.
#

export def IsFugitiveBuf(): bool
  try
    fugitive#repo()
  catch /not a Git repository/
    return v:false
  endtry
  return v:true
enddef

export def GetRelativePath(workdir: string, path: string): string
  var full_path = fnamemodify(path, ':p')
  if stridx(full_path, workdir) == 0
    return full_path[len(workdir) + 1 : ]
  endif
  return path
enddef

export def GetRepo(): dict<any>
  return fugitive#repo()
enddef

export def GetWorkdir(): string
  return GetRepo().tree()
enddef

export def GetGitDir(): string
  return GetRepo().dir()
enddef

export def GetGitCommand(): string
  return g:FugitiveShellCommand()
enddef

export def GetHead(): string
  return fugitive#head()
enddef

export def TriggerDetection(workdir: string): string
  g:FugitiveDetect(workdir)
  return workdir
enddef

export def Complete(arg_lead: string, cmd_line: string, cursor_pos: number): list<string>
  return fugitive#Complete(arg_lead, cmd_line, cursor_pos)
enddef
