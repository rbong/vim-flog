vim9script

#
# This file contains utility functions for "flog#exec()".
#

def flog#exec#get_cache_refs(cache: dict<any>, commit: dict<any>): list<dict<any>>
  var ref_cache = cache.refs

  const refs = flog#state#get_commit_refs(commit)

  ref_cache[commit.hash] = refs
  return refs
enddef

def flog#exec#format_hash(save: bool): string
  const commit = flog#floggraph#commit#get_at_line('.')
  
  if !empty(commit)
    if save
      flog#floggraph#mark#set_internal('!', '.')
    endif
    return commit.hash
  endif

  return ''
enddef

def flog#exec#format_mark_hash(key: string): string
  const commit = flog#floggraph#mark#get(key)
  return empty(commit) ? '' : commit.hash
enddef

def flog#exec#format_commit_branch(cache: dict<any>, commit: dict<any>): string
  var local_branch = ''
  var remote_branch = ''

  for ref in flog#exec#get_cache_refs(cache, commit)
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

  return empty(local_branch) ? remote_branch : local_branch
enddef

def flog#exec#format_branch(cache: dict<any>): string
  const commit = flog#floggraph#commit#get_at_line('.')
  return flog#exec#format_commit_branch(cache, commit)
enddef

def flog#exec#format_mark_branch(cache: dict<any>, key: string): string
  const commit = flog#floggraph#mark#get(key)
  return flog#exec#format_commit_branch(cache, commit)
enddef

def flog#exec#format_commit_local_branch(cache: dict<any>, commit: dict<any>): string
  var branch = flog#exec#format_commit_branch(cache, commit)
  return substitute(branch, '.*/', '', '')
enddef

def flog#exec#format_local_branch(cache: dict<any>): string
  const commit = flog#floggraph#commit#get_at_line('.')
  return flog#exec#format_commit_local_branch(cache, commit)
enddef

def flog#exec#format_mark_local_branch(cache: dict<any>, key: string): string
  const commit = flog#floggraph#mark#get(key)
  return flog#exec#format_commit_local_branch(cache, commit)
enddef

def flog#exec#format_path(): string
  const state = flog#state#get_buf_state()
  var path = state.opts.path

  if !empty(state.opts.limit)
    const [range, limit_path] = flog#args#split_git_limit_arg(state.opts.limit)

    if empty(limit_path)
      return ''
    endif

    path = [limit_path]
  elseif empty(path)
    return ''
  endif

  return join(flog#shell#escape_list(path), ' ')
enddef

def flog#exec#format_item(cache: dict<any>, item: string): string
  var item_cache = cache.items

  # Return cached items

  if has_key(item_cache, item)
    return item_cache[item]
  endif

  # Format the item

  var formatted_item = ''

  if item == 'h'
    formatted_item = flog#exec#format_hash(true)
  elseif item == 'H'
    formatted_item = flog#exec#format_hash(false)
  elseif item =~ "^h'."
    formatted_item = flog#exec#format_mark_hash(item[2 : ])
  elseif item =~ 'b'
    formatted_item = flog#exec#format_branch(cache)
  elseif item =~ "^b'."
    formatted_item = flog#exec#format_mark_branch(cache, item[2 : ])
  elseif item =~ 'l'
    formatted_item = flog#exec#format_local_branch(cache)
  elseif item =~ "^l'."
    formatted_item = flog#exec#format_mark_local_branch(cache, item[2 : ])
  elseif item == 'p'
    formatted_item = flog#exec#format_path()
  else
    echoerr printf('error converting "%s"', item)
    throw g:flog_unsupported_exec_format_item
  endif

  # Handle result
  item_cache[item] = formatted_item
  return formatted_item
enddef

def flog#exec#format(str: string): string
  flog#floggraph#buf#assert_flog_buf()

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
        const formatted_item = flog#exec#format_item(cache, long_item)
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
        const formatted_item = flog#exec#format_item(cache, char)
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
