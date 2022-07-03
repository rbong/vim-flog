"
" This file contains utility functions for "flog#Exec()".
"

function! flog#exec#GetCacheRefs(cache, commit) abort
  let l:ref_cache = a:cache.refs

  let l:refs = flog#state#GetCommitRefs(a:commit)

  let l:ref_cache[a:commit.hash] = l:refs
  return l:refs
endfunction

function! flog#exec#FormatHash(save) abort
  let l:commit = flog#floggraph#commit#GetAtLine('.')
  
  if !empty(l:commit)
    if a:save
      call flog#floggraph#mark#SetInternal('!', '.')
    endif
    return l:commit.hash
  endif

  return ''
endfunction

function! flog#exec#FormatMarkHash(key) abort
  let l:commit = flog#floggraph#mark#Get(a:key)
  return empty(l:commit) ? '' : l:commit.hash
endfunction

function! flog#exec#FormatCommitBranch(cache, commit) abort
  let l:local_branch = ''
  let l:remote_branch = ''

  for l:ref in flog#exec#GetCacheRefs(a:cache, a:commit)
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

function! flog#exec#FormatBranch(cache) abort
  let l:commit = flog#floggraph#commit#GetAtLine('.')
  return flog#exec#FormatCommitBranch(a:cache, l:commit)
endfunction

function! flog#exec#FormatMarkBranch(cache, key) abort
  let l:commit = flog#floggraph#mark#Get(a:key)
  return flog#exec#FormatCommitBranch(a:cache, l:commit)
endfunction

function! flog#exec#FormatCommitLocalBranch(cache, commit) abort
  let l:branch = flog#exec#FormatCommitBranch(a:cache, a:commit)
  return substitute(l:branch, '.*/', '', '')
endfunction

function! flog#exec#FormatLocalBranch(cache) abort
  let l:commit = flog#floggraph#commit#GetAtLine('.')
  return flog#exec#FormatCommitLocalBranch(a:cache, l:commit)
endfunction

function! flog#exec#FormatMarkLocalBranch(cache, key) abort
  let l:commit = flog#floggraph#mark#Get(a:key)
  return flog#exec#FormatCommitLocalBranch(a:cache, l:commit)
endfunction

function! flog#exec#FormatPath() abort
  let l:state = flog#state#GetBufState()
  let l:path = l:state.opts.path

  if !empty(l:state.opts.limit)
    let [l:range, l:limit_path] = flog#args#SplitGitLimitArg(l:state.opts.limit)

    if empty(l:limit_path)
      return ''
    endif

    let l:path = [l:limit_path]
  elseif empty(l:path)
    return ''
  endif

  return join(flog#shell#EscapeList(l:path), ' ')
endfunction

function! flog#exec#FormatIndexTree(cache) abort
  if empty(a:cache.index_tree)
    let l:cmd = flog#fugitive#GetGitCommand()
    let l:cmd .= ' write-tree'
    let a:cache.index_tree = flog#shell#Run(l:cmd)[0]
  endif
  return a:cache.index_tree
endfunction

function! flog#exec#FormatItem(cache, item) abort
  let l:item_cache = a:cache.items

  " Return cached items

  if has_key(l:item_cache, a:item)
    return l:item_cache[a:item]
  endif

  " Format the item

  let l:formatted_item = ''

  if a:item ==# 'h'
    let l:formatted_item = flog#exec#FormatHash(v:true)
  elseif a:item ==# 'H'
    let l:formatted_item = flog#exec#FormatHash(v:false)
  elseif a:item =~# "^h'."
    let l:formatted_item = flog#exec#FormatMarkHash(a:item[2 : ])
  elseif a:item =~# 'b'
    let l:formatted_item = flog#exec#FormatBranch(a:cache)
  elseif a:item =~# "^b'."
    let l:formatted_item = flog#exec#FormatMarkBranch(a:cache, a:item[2 : ])
  elseif a:item =~# 'l'
    let l:formatted_item = flog#exec#FormatLocalBranch(a:cache)
  elseif a:item =~# "^l'."
    let l:formatted_item = flog#exec#FormatMarkLocalBranch(a:cache, a:item[2 : ])
  elseif a:item ==# 'p'
    let l:formatted_item = flog#exec#FormatPath()
  elseif a:item ==# 't'
    let l:formatted_item = flog#exec#FormatIndexTree(a:cache)
  else
    echoerr printf('error converting "%s"', a:item)
    throw g:flog_unsupported_exec_format_item
  endif

  " Handle result
  let l:item_cache[a:item] = l:formatted_item
  return l:formatted_item
endfunction

function! flog#exec#Format(str) abort
  call flog#floggraph#buf#AssertFlogBuf()

  " Special token flags
  let l:is_in_item = v:false
  let l:is_in_long_item = v:false

  " Special token data
  let l:long_item = ''

  " Memoized data
  let l:cache = {
        \ 'items': {},
        \ 'refs': {},
        \ 'index_tree': '',
        \ }

  " Return data
  let l:result = ''

  for l:char in split(a:str, '\zs')
    if l:is_in_long_item
      " Parse characters in %()

      if l:char ==# ')'
        " End long specifier
        let l:formatted_item = flog#exec#FormatItem(l:cache, l:long_item)
        if empty(l:formatted_item)
          return ''
        endif

        let l:result .= l:formatted_item
        let l:is_in_long_item = v:false
        let l:long_item = ''
      else
        let l:long_item .= l:char
      endif
    elseif l:is_in_item
      " Parse character after %

      if l:char ==# '('
        " Start long specifier
        let l:is_in_long_item = v:true
      else
        " Parse specifier character
        let l:formatted_item = flog#exec#FormatItem(l:cache, l:char)
        if empty(l:formatted_item)
          return ''
        endif

        let l:result .= l:formatted_item
      endif

      let l:is_in_item = v:false
    elseif l:char ==# '%'
      " Start specifier
      let l:is_in_item = v:true
    else
      " Append normal character
      let l:result .= l:char
    endif
  endfor

  return l:result
endfunction
