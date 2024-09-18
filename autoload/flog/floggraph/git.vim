"
" This file contains functions for working with git for "floggraph" buffers.
"

function! flog#floggraph#git#HandleDynamicLogFormatItem(dict, item, end) abort
  if a:item ==# '%d' || a:item ==# '%D'
    " Ref names
    let a:dict.result .= "\e[r" . a:item . "\e[R"
    return 1
  elseif a:item =~# '^%[hHpPtT]$'
    " Hash
    let a:dict.result .= "\e[h" . a:item . "\e[H"
    return 1
  elseif !a:end && (a:item ==# '%a' || a:item ==# '%c')
    " Partial item
    return 0
  elseif a:item =~# '^%[ac][dDrtiIsh]$'
    " Date
    let a:dict.result .= "\e[d" . a:item . "\e[D"
    return 1
  elseif a:item =~# '^%[ac].$'
    " Name
    let a:dict.result .= "\e[n" . a:item . "\e[N"
    return 1
  endif

  " Other
  let a:dict.result .= a:item
  return 1
endfunction

function! flog#floggraph#git#BuildDynamicLogFormat(str) abort
  let l:dict = { 'result': '' }
  call flog#format#ParseFormat(
        \ a:str,
        \ l:dict,
        \ function('flog#floggraph#git#HandleDynamicLogFormatItem'))
  return l:dict.result
endfunction

function! flog#floggraph#git#BuildLogFormat() abort
  let l:state = flog#state#GetBufState()
  let l:opts = flog#state#GetResolvedOpts(l:state)

  let l:format = 'format:'
  " Add token so we can find commits
  let l:format .= g:flog_commit_start_token
  " Add commit data
  let l:format .= '%n%h%n%p%n%D%n'
  " Add user format
  if g:flog_enable_dynamic_commit_hl
    let l:format .= flog#floggraph#git#BuildDynamicLogFormat(l:opts.format)
  else
    let l:format .= l:opts.format
  endif

  return flog#shell#Escape(l:format)
endfunction

function! flog#floggraph#git#BuildLogArgs() abort
  let l:state = flog#state#GetBufState()
  let l:opts = flog#state#GetResolvedOpts(l:state)

  if l:opts.reverse && l:opts.graph
    throw g:flog_reverse_requires_no_graph
  endif

  let l:args = ''

  if l:opts.graph
    let l:args .= ' --parents --topo-order'
  endif
  let l:args .= ' --no-color'
  let l:args .= ' --pretty=' . flog#floggraph#git#BuildLogFormat()
  let l:args .= ' --date=' . flog#shell#Escape(l:opts.date)
  if l:opts.all && empty(l:opts.limit)
    let l:args .= ' --all'
  endif
  if l:opts.bisect
    let l:args .= ' --bisect'
  endif
  if l:opts.first_parent
    let l:args .= ' --first-parent'
  endif
  if !l:opts.merges
    let l:args .= ' --no-merges'
  endif
  if l:opts.reflog
    let l:args .= ' --reflog'
  endif
  if l:opts.reverse
    let l:args .= ' --reverse'
  endif
  if l:opts.patch == v:true
    let l:args .= ' --patch'
  elseif l:opts.patch == v:false
    let l:args .= ' --no-patch'
  endif
  if !empty(l:opts.skip)
    let l:args .= ' --skip=' . flog#shell#Escape(l:opts.skip)
  endif
  if !empty(l:opts.order)
    let l:order_type = flog#global_opts#GetOrderType(l:opts.order)
    let l:args .= ' ' . l:order_type.args
  endif
  if !empty(l:opts.max_count)
    let l:args .= ' --max-count=' . flog#shell#Escape(l:opts.max_count)
  endif
  if !empty(l:opts.search)
    let l:args .= ' --grep=' . flog#shell#Escape(l:opts.search)
  endif
  if !empty(l:opts.patch_search)
    let l:args .= ' -G' . flog#shell#Escape(l:opts.patch_search)
  endif
  if !empty(l:opts.author)
    let l:args .= ' --author=' . flog#shell#Escape(l:opts.author)
  endif
  if !empty(l:opts.limit)
    let l:args .= ' -L' . flog#shell#Escape(l:opts.limit)
  endif
  if !empty(l:opts.raw_args)
    let l:args .= ' ' . l:opts.raw_args
  endif
  if len(l:opts.rev) >= 1 || (empty(l:opts.limit) && l:opts.related)
    let l:rev = ''

    if !empty(l:opts.limit)
      " The -L flag only supports a single rev, use only the first rev
      let l:rev = flog#shell#Escape(l:opts.rev[0])
    else
      " No -L flag, use all revs
      let l:revs = l:opts.rev

      if l:opts.related
        " Include related refs
        let l:revs = uniq(sort(flog#git#GetRelatedRefs(l:revs) + l:revs))
      endif

      let l:rev = join(flog#shell#EscapeList(l:revs), ' ')
    endif

    let l:args .= ' ' . l:rev
  endif

  return l:args
endfunction

function! flog#floggraph#git#BuildLogPaths() abort
  let l:state = flog#state#GetBufState()
  let l:opts = flog#state#GetResolvedOpts(l:state)

  if !empty(l:opts.limit)
    return ''
  endif

  if empty(l:opts.path)
    return ''
  endif

  return join(flog#shell#EscapeList(l:opts.path), ' ')
endfunction

function! flog#floggraph#git#BuildLogCmd() abort
  let l:cmd = join(flog#git#GetCommand(['log']), ' ')

  let l:cmd .= flog#floggraph#git#BuildLogArgs()
  let l:cmd .= ' -- '
  let l:cmd .= flog#floggraph#git#BuildLogPaths()

  return l:cmd
endfunction
