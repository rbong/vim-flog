vim9script

#
# This file contains utility functions for "flog#Exec()".
#

export def GetCacheRefs(cache: dict<any>, commit: dict<any>): list<dict<any>>
  var ref_cache = cache.refs

  const refs = flog#state#GetCommitRefs(commit)

  ref_cache[commit.hash] = refs
  return refs
enddef

export def FormatHash(save: bool): string
  const commit = flog#floggraph#commit#GetAtLine('.')
  
  if !empty(commit)
    if save
      flog#floggraph#mark#SetInternal('!', '.')
    endif
    return commit.hash
  endif

  return ''
enddef

export def FormatMarkHash(key: string): string
  const commit = flog#floggraph#mark#Get(key)
  return empty(commit) ? '' : commit.hash
enddef

export def FormatCommitBranch(cache: dict<any>, commit: dict<any>): string
  var local_branch = ''
  var remote_branch = ''

  for ref in flog#exec#GetCacheRefs(cache, commit)
    # Skip non-branches
    if ref.tag || ref.tail =~ 'HEAD$'
      continue
    endif

    # Get local branch
    if empty(ref.remote) && empty(ref.prefix)
      local_branch = ref.tail
      break
    endif

    # Get remote branch
    if empty(remote_branch) && !empty(ref.remote)
      remote_branch = ref.path
    endif
  endfor

  const branch = empty(local_branch) ? remote_branch : local_branch

  return flog#shell#Escape(branch)
enddef

export def FormatBranch(cache: dict<any>): string
  const commit = flog#floggraph#commit#GetAtLine('.')
  return flog#exec#FormatCommitBranch(cache, commit)
enddef

export def FormatMarkBranch(cache: dict<any>, key: string): string
  const commit = flog#floggraph#mark#Get(key)
  return flog#exec#FormatCommitBranch(cache, commit)
enddef

export def FormatCommitLocalBranch(cache: dict<any>, commit: dict<any>): string
  var branch = flog#exec#FormatCommitBranch(cache, commit)
  return substitute(branch, '.*/', '', '')
enddef

export def FormatLocalBranch(cache: dict<any>): string
  const commit = flog#floggraph#commit#GetAtLine('.')
  return flog#exec#FormatCommitLocalBranch(cache, commit)
enddef

export def FormatMarkLocalBranch(cache: dict<any>, key: string): string
  const commit = flog#floggraph#mark#Get(key)
  return flog#exec#FormatCommitLocalBranch(cache, commit)
enddef

export def FormatPath(): string
  const state = flog#state#GetBufState()
  var path = state.opts.path

  if !empty(state.opts.limit)
    const [range, limit_path] = flog#args#SplitGitLimitArg(state.opts.limit)

    if empty(limit_path)
      return ''
    endif

    path = [limit_path]
  elseif empty(path)
    return ''
  endif

  return join(flog#shell#EscapeList(path), ' ')
enddef

export def FormatItem(cache: dict<any>, item: string): string
  var item_cache = cache.items

  # Return cached items

  if has_key(item_cache, item)
    return item_cache[item]
  endif

  # Format the item

  var formatted_item = ''

  if item == 'h'
    formatted_item = flog#exec#FormatHash(true)
  elseif item == 'H'
    formatted_item = flog#exec#FormatHash(false)
  elseif item =~ "^h'."
    formatted_item = flog#exec#FormatMarkHash(item[2 : ])
  elseif item =~ 'b'
    formatted_item = flog#exec#FormatBranch(cache)
  elseif item =~ "^b'."
    formatted_item = flog#exec#FormatMarkBranch(cache, item[2 : ])
  elseif item =~ 'l'
    formatted_item = flog#exec#FormatLocalBranch(cache)
  elseif item =~ "^l'."
    formatted_item = flog#exec#FormatMarkLocalBranch(cache, item[2 : ])
  elseif item == 'p'
    formatted_item = flog#exec#FormatPath()
  else
    echoerr printf('error converting "%s"', item)
    throw g:flog_unsupported_exec_format_item
  endif

  # Handle result
  item_cache[item] = formatted_item
  return formatted_item
enddef

export def Format(str: string): string
  flog#floggraph#buf#AssertFlogBuf()

  # Special token flags
  var is_in_item = false
  var is_in_long_item = false

  # Special token data
  var long_item = ''

  # Memoized data
  var cache = {
    'items': {},
    'refs': {},
    }

  # Return data
  var result = ''

  for char in split(str, '\zs')
    if is_in_long_item
      # Parse characters in %()

      if char == ')'
        # End long specifier
        const formatted_item = flog#exec#FormatItem(cache, long_item)
        if empty(formatted_item)
          return ''
        endif

        result ..= formatted_item
        is_in_long_item = false
        long_item = ''
      else
        long_item ..= char
      endif
    elseif is_in_item
      # Parse character after %

      if char == '('
        # Start long specifier
        is_in_long_item = true
      else
        # Parse specifier character
        const formatted_item = flog#exec#FormatItem(cache, char)
        if empty(formatted_item)
          return ''
        endif

        result ..= formatted_item
      endif

      is_in_item = false
    elseif char == '%'
      # Start specifier
      is_in_item = true
    else
      # Append normal character
      result ..= char
    endif
  endfor

  return result
enddef
