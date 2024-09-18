"
" This file contains functions for formatting contextual Floggraph command specifiers.
"

function! flog#floggraph#format#GetCacheCmdRefs(dict, commit) abort
  let l:refs = flog#state#GetCommitRefs(a:commit)
  let a:dict.refs[a:commit.hash] = l:refs
  return l:refs
endfunction

function! flog#floggraph#format#FormatHash(save) abort
  let l:commit = flog#floggraph#commit#GetAtLine('.')
  
  if !empty(l:commit)
    if a:save
      call flog#floggraph#mark#SetInternal('!', '.')
    endif
    return l:commit.hash
  endif

  return ''
endfunction

function! flog#floggraph#format#FormatMarkHash(key) abort
  let l:commit = flog#floggraph#mark#Get(a:key)
  return empty(l:commit) ? '' : l:commit.hash
endfunction

function! flog#floggraph#format#FormatMarkHashRange(range) abort
  let l:state = flog#state#GetBufState()

  let l:range = split(a:range, ',')
  if len(l:range) != 2
    return ''
  endif
  let l:start_mark = l:range[0][1:]
  let l:end_mark = l:range[1][1:]

  let l:start_commit = flog#floggraph#mark#Get(l:start_mark)
  let l:end_commit = flog#floggraph#mark#Get(l:end_mark)
  if empty(l:start_commit) || empty(l:end_commit)
    return ''
  endif

  let l:start_line = l:start_commit.line
  let l:end_line = l:end_commit.line
  let l:step = l:start_line <= l:end_line ? 1 : -1

  let l:commit_index = flog#floggraph#commit#GetIndexAtLine(l:start_line)
  if l:commit_index < 0
    return ''
  endif

  let l:hashes = []
  while v:true
    let l:commit = get(l:state.commits, l:commit_index, {})
    if empty(l:commit)
      break
    endif
    if l:step > 0 && l:commit.line > l:end_line
      break
    endif
    if l:step < 0 && l:commit.line < l:end_commit.line
      break
    endif

    call add(l:hashes, l:commit.hash)
    let l:commit_index += l:step
    if l:commit_index < 0
      break
    endif
  endwhile

  return join(l:hashes, ' ')
endfunction

function! flog#floggraph#format#FormatCommitBranch(dict, commit) abort
  let l:local_branch = ''
  let l:remote_branch = ''

  for l:ref in flog#floggraph#format#GetCacheCmdRefs(a:dict, a:commit)
    " Skip non-branches
    if l:ref.tag || l:ref.tail =~# 'HEAD$'
      continue
    endif

    " Get local branch
    if empty(l:ref.remote) && empty(l:ref.prefix)
      let l:local_branch = l:ref.tail
      break
    endif

    " Get remote branch
    if empty(l:remote_branch) && !empty(l:ref.remote)
      let l:remote_branch = l:ref.path
    endif
  endfor

  let l:branch = empty(l:local_branch) ? l:remote_branch : l:local_branch

  return flog#shell#Escape(l:branch)
endfunction

function! flog#floggraph#format#FormatBranch(dict) abort
  let l:commit = flog#floggraph#commit#GetAtLine('.')
  return flog#floggraph#format#FormatCommitBranch(a:dict, l:commit)
endfunction

function! flog#floggraph#format#FormatMarkBranch(dict, key) abort
  let l:commit = flog#floggraph#mark#Get(a:key)
  return flog#floggraph#format#FormatCommitBranch(a:dict, l:commit)
endfunction

function! flog#floggraph#format#FormatCommitLocalBranch(dict, commit) abort
  let l:branch = flog#floggraph#format#FormatCommitBranch(a:dict, a:commit)
  return substitute(l:branch, '.\{-}/', '', '')
endfunction

function! flog#floggraph#format#FormatLocalBranch(dict) abort
  let l:commit = flog#floggraph#commit#GetAtLine('.')
  return flog#floggraph#format#FormatCommitLocalBranch(a:dict, l:commit)
endfunction

function! flog#floggraph#format#FormatMarkLocalBranch(dict, key) abort
  let l:commit = flog#floggraph#mark#Get(a:key)
  return flog#floggraph#format#FormatCommitLocalBranch(a:dict, l:commit)
endfunction

function! flog#floggraph#format#FormatPath(separate_args) abort
  let l:state = flog#state#GetBufState()
  let l:path = l:state.opts.path

  if !empty(l:state.opts.limit)
    let [l:range, l:limit_path] = flog#args#SplitGitLimitArg(l:state.opts.limit)

    if empty(l:limit_path)
      return a:separate_args ? '--' : ''
    endif

    let l:path = [l:limit_path]
  elseif empty(l:path)
    return a:separate_args ? '--' : ''
  endif

  let l:paths = join(flog#shell#EscapeList(l:path), ' ')
  return a:separate_args ? '-- ' .. l:paths : l:paths
endfunction

function! flog#floggraph#format#FormatIndexTree(dict) abort
  if empty(a:dict.index_tree)
    let l:cmd = flog#git#GetCommand(['write-tree'])
    let a:dict.index_tree = flog#shell#Run(l:cmd)[0]
  endif
  return a:dict.index_tree
endfunction

function! flog#floggraph#format#HandleCommandItem(dict, item, end) abort
  let l:items = a:dict.items

  let l:formatted_item = ''
  let l:save = v:true

  if a:item !~# '^%'
    let l:formatted_item = a:item
    let l:save = v:false
  elseif has_key(l:items, a:item)
    let l:formatted_item = l:items[a:item]
    let l:save = v:false
  elseif a:item ==# '%%'
    let l:formatted_item = '%'
  elseif a:item ==# '%h'
    let l:formatted_item = flog#floggraph#format#FormatHash(v:true)
  elseif a:item ==# '%H'
    let l:formatted_item = flog#floggraph#format#FormatHash(v:false)
  elseif a:item =~# "^%(h'.\\+,'."
    let l:formatted_item = flog#floggraph#format#FormatMarkHashRange(a:item[3 : -2])
  elseif a:item =~# "^%(h'."
    let l:formatted_item = flog#floggraph#format#FormatMarkHash(a:item[4 : -2])
  elseif a:item =~# '%b'
    let l:formatted_item = flog#floggraph#format#FormatBranch(a:dict)
  elseif a:item =~# "^%(b'."
    let l:formatted_item = flog#floggraph#format#FormatMarkBranch(a:dict, a:item[4 : -2])
  elseif a:item =~# '%l'
    let l:formatted_item = flog#floggraph#format#FormatLocalBranch(a:dict)
  elseif a:item =~# "^%(l'."
    let l:formatted_item = flog#floggraph#format#FormatMarkLocalBranch(a:dict, a:item[4 : -2])
  elseif a:item ==# '%p'
    let l:formatted_item = flog#floggraph#format#FormatPath(v:false)
  elseif a:item ==# '%P'
    let l:formatted_item = flog#floggraph#format#FormatPath(v:true)
  elseif a:item ==# '%t'
    let l:formatted_item = flog#floggraph#format#FormatIndexTree(a:dict)
  else
    call flog#print#err('error converting "%s"', a:item)
    throw g:flog_unsupported_exec_format_item
  endif

  if empty(l:formatted_item)
    let a:dict.result = ''
    return -1
  endif

  if l:save
    let l:items[a:item] = l:formatted_item
  endif

  let a:dict.result .= l:formatted_item
  return 1
endfunction

function! flog#floggraph#format#FormatCommand(str) abort
  call flog#floggraph#buf#AssertFlogBuf()

  let l:dict = {
        \ 'items': {},
        \ 'refs': {},
        \ 'index_tree': '',
        \ 'result': '',
        \ }

  call flog#format#ParseFormat(a:str, l:dict, function("flog#floggraph#format#HandleCommandItem"))

  return l:dict.result
endfunction
