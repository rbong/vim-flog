vim9script

#
# This file contains functions for working with Fugitive.
#

export def IsFugitiveBuf(): bool
  return g:FugitiveIsGitDir()
enddef

export def GetRelativePath(workdir: string, path: string): string
  var full_path = fnamemodify(path, ':p')
  if stridx(full_path, workdir) == 0
    return full_path[len(workdir) + 1 : ]
  endif
  return path
enddef

export def GetWorkdir(): string
  return g:FugitiveFind(":/")
enddef

export def GetGitDir(): string
  return g:FugitiveGitDir()
enddef

export def GetGitCommand(): string
  return g:FugitiveShellCommand()
enddef

export def GetHead(): string
  return fugitive#Head()
enddef

export def TriggerDetection(workdir: string): string
  g:FugitiveDetect(workdir)
  return workdir
enddef

export def Complete(arg_lead: string, cmd_line: string, cursor_pos: number): list<string>
  return fugitive#Complete(arg_lead, cmd_line, cursor_pos)
enddef
