"
" This file contains functions for handling args to commands.
"

function! flog#args#SplitArg(arg) abort
  let l:match = matchlist(a:arg, '\v(.{-}(\=|$))(.*)')
  return [l:match[1], l:match[3]]
endfunction

function! flog#args#GetRelativePath(workdir, path) abort
  let l:full_path = fnamemodify(a:path, ':p')
  if stridx(l:full_path, a:workdir) == 0
    return l:full_path[len(a:workdir) + 1 : ]
  endif
  return a:path
endfunction

function! flog#args#ParseArg(arg) abort
  return flog#args#SplitArg(a:arg)[1]
endfunction

function! flog#args#UnescapeArg(arg) abort
  let l:unescaped = ''
  let l:is_escaped = v:false

  for l:char in split(a:arg, '\zs')
    if l:char ==# '\' && !l:is_escaped
      let l:is_escaped = v:true
    else
      let l:unescaped .= l:char
      let l:is_escaped = v:false
    endif
  endfor

  return l:unescaped
endfunction

function! flog#args#SplitGitLimitArg(limit) abort
  let [l:match, l:start, l:end] = matchstrpos(a:limit, '^.\{1,}:\zs')
  if l:start < 0
    return [a:limit, '']
  endif
  return [a:limit[ : l:start - 1], a:limit[l:start : ]]
endfunction

function! flog#args#ParseGitLimitArg(workdir, arg) abort
  let l:arg_opt = flog#args#ParseArg(a:arg)
  let [l:range, l:path] = flog#args#SplitGitLimitArg(l:arg_opt)

  if empty(l:path)
    return l:arg_opt
  endif

  return l:range . flog#args#GetRelativePath(a:workdir, expand(l:path))
endfunction

function! flog#args#ParseGitPathArg(workdir, arg) abort
  let l:arg_opt = flog#args#ParseArg(a:arg)
  return flog#args#GetRelativePath(a:workdir, expand(l:arg_opt))
endfunction

function! flog#args#FilterCompletions(arg_lead, completions) abort
  let l:lead = '^' . escape(a:arg_lead, '\\')
  return filter(copy(a:completions), 'v:val =~# l:lead')
endfunction

function! flog#args#EscapeCompletions(lead, completions) abort
  return map(copy(a:completions), 'a:lead . substitute(v:val, " ", "\\\\ ", "g")')
endfunction
