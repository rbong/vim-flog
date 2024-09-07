"
" This file contains functions for handling args to the ":Flog" command.
"

" Parse ":Flog" args into the options object.
function! flog#cmd#flog#args#Parse(current_opts, workdir, args) abort
  let l:defaults = flog#state#GetInternalDefaultOpts()

  let l:has_set_path = v:false

  let l:has_set_rev = v:false

  let l:has_set_raw_args = v:false
  let l:got_raw_args_token = v:false
  let l:raw_args = []

  for l:arg in a:args
    if l:got_raw_args_token
      let l:has_set_raw_args = v:true
      let l:raw_args += [l:arg]
    elseif l:arg ==# '--'
      let l:got_raw_args_token = v:true
    elseif l:arg =~# '^-format=.\+'
      let a:current_opts.format = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-format='
      let a:current_opts.format = l:defaults.format
    elseif l:arg =~# '^-date=.\+'
      let a:current_opts.date = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-date='
      let a:current_opts.date = l:defaults.date
    elseif l:arg =~# '^-raw-args=.\+'
      let l:has_set_raw_args = v:true
      let l:raw_args += [flog#args#ParseArg(l:arg)]
    elseif l:arg ==# '-raw-args='
      let l:has_set_raw_args = v:false
      let a:current_opts.raw_args = l:defaults.raw_args
    elseif l:arg ==# '-all'
      let a:current_opts.all = v:true
    elseif l:arg ==# '-no-all'
      let a:current_opts.all = v:false
    elseif l:arg ==# '-auto-update'
      let a:current_opts.auto_update = v:true
    elseif l:arg ==# '-no-auto-update'
      let a:current_opts.auto_update = v:false
    elseif l:arg ==# '-bisect'
      let a:current_opts.bisect = v:true
    elseif l:arg ==# '-no-bisect'
      let a:current_opts.bisect = v:false
    elseif l:arg ==# '-default-collapsed'
      let a:current_opts.default_collapsed = v:true
    elseif l:arg ==# '-default-expanded'
      let a:current_opts.default_collapsed = v:false
    elseif l:arg ==# '-first-parent'
      let a:current_opts.first_parent = v:true
    elseif l:arg ==# '-no-first-parent'
      let a:current_opts.first_parent = v:false
    elseif l:arg ==# '-merges'
      let a:current_opts.merges = v:true
    elseif l:arg ==# '-no-merges'
      let a:current_opts.merges = v:false
    elseif l:arg ==# '-reflog'
      let a:current_opts.reflog = v:true
    elseif l:arg ==# '-no-reflog'
      let a:current_opts.reflog = v:false
    elseif l:arg ==# '-related'
      let a:current_opts.related = v:true
    elseif l:arg ==# '-no-related'
      let a:current_opts.related = v:false
    elseif l:arg ==# '-reverse'
      let a:current_opts.reverse = v:true
    elseif l:arg ==# '-no-reverse'
      let a:current_opts.reverse = v:false
    elseif l:arg ==# '-graph'
      let a:current_opts.graph = v:true
    elseif l:arg ==# '-no-graph'
      let a:current_opts.graph = v:false
    elseif l:arg ==# '-patch'
      let a:current_opts.patch = v:true
    elseif l:arg ==# '-no-patch'
      let a:current_opts.patch = v:false
    elseif l:arg ==# '-patch='
      let a:current_opts.patch = -1
    elseif l:arg =~# '^-skip=\d\+'
      let a:current_opts.skip = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-skip='
      let a:current_opts.skip = l:defaults.skip
    elseif l:arg =~# '^-\(order\|sort\)=.\+'
      let a:current_opts.order = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-order=' || l:arg ==# '-sort='
      let a:current_opts.order = l:defaults.order
    elseif l:arg =~# '^-max-count=\d\+'
      let a:current_opts.max_count = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-max-count='
      let a:current_opts.max_count = l:defaults.max_count
    elseif l:arg =~# '^-open-cmd=.\+'
      let a:current_opts.open_cmd = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-open-cmd='
      let a:current_opts.open_cmd = l:defaults.open_cmd
    elseif l:arg =~# '^-\(search\|grep\)=.\+'
      let a:current_opts.search = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-search=' || l:arg ==# '-grep='
      let a:current_opts.search = l:defaults.search
    elseif l:arg =~# '^-patch-\(search\|grep\)=.\+'
      let a:current_opts.patch_search = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-patch-search=' || l:arg ==# '-patch-grep='
      let a:current_opts.patch_search = l:defaults.patch_search
    elseif l:arg =~# '^-author=.\+'
      let a:current_opts.author = flog#args#ParseArg(l:arg)
    elseif l:arg ==# '-author='
      let a:current_opts.author = l:defaults.author
    elseif l:arg =~# '^-limit=.\+'
      let a:current_opts.limit = flog#args#ParseGitLimitArg(a:workdir, l:arg)
    elseif l:arg ==# '-limit='
      let a:current_opts.limit = l:defaults.limit
    elseif l:arg =~# '^-rev=.\+'
      if !l:has_set_rev
        let a:current_opts.rev = []
        let l:has_set_rev = v:true
      endif
      call add(a:current_opts.rev, flog#args#ParseArg(l:arg))
    elseif l:arg ==# '-rev='
      let l:has_set_rev = v:false
      let a:current_opts.rev = l:defaults.rev
    elseif l:arg =~# '^-path=.\+'
      if !l:has_set_path
        let a:current_opts.path = []
        let l:has_set_path = v:true
      endif
      call add(a:current_opts.path, flog#args#ParseGitPathArg(a:workdir, l:arg))
    elseif l:arg ==# '-path='
      let a:current_opts.path = l:defaults.path
      let l:has_set_path = v:false
    else
      call flog#print#err('error parsing argument "%s"', l:arg)
      throw g:flog_unsupported_argument
    endif
  endfor

  if l:has_set_raw_args
    let a:current_opts.raw_args = join(l:raw_args, ' ')
  endif

  return a:current_opts
endfunction

function! flog#cmd#flog#args#CompleteFormat(arg_lead) abort
  let l:is_escaped = v:false
  let l:current_specifier = ''
  let l:current_parens = ''

  " Find last specifier (handles escaped % signs)
  for l:c in a:arg_lead
    if l:c ==# '%'
      if l:current_specifier ==# '%'
        " Literal percent
        let l:current_specifier = '%%'
      else
        " New specifier
        let l:current_specifier = '%'
        let l:current_parens = ''
      endif
    elseif l:current_specifier ==# ''
      continue
    elseif l:current_specifier ==# '%%'
      let l:current_specifier = ''
      let l:current_parens = ''
    elseif l:current_specifier =~# '($'
      if l:c ==# ')'
        " End of parens/specifier
        let l:current_specifier = ''
        let l:current_parens = ''
      else
        " Inside parens
        let l:current_parens .= l:c
      endif
    else
      let l:current_specifier .= l:c
    endif
  endfor

  " Inside of parens, end parens
  if !empty(l:current_parens)
    return [a:arg_lead . ')']
  endif

  let l:completions = []
  let l:l = len(l:current_specifier)

  " Find specifiers that start with the current specifier
  if l:l > 0
    let l:prefix = a:arg_lead[ : -l:l - 1]

    for l:specifier in g:flog_format_specifiers
      if stridx(specifier, l:current_specifier) == 0
        call add(l:completions, l:prefix . l:specifier)
      endif
    endfor
  endif

  " No specifier, start a new one
  if empty(l:completions)
    return [a:arg_lead . '%']
  endif

  return l:completions
endfunction

function! flog#cmd#flog#args#CompleteDate(arg_lead) abort
  let [l:lead, _] = flog#args#SplitArg(a:arg_lead)
  let l:completions = map(copy(g:flog_date_formats), 'l:lead . v:val')
  return flog#args#FilterCompletions(a:arg_lead, l:completions)
endfunction

function! flog#cmd#flog#args#CompleteOpenCmd(arg_lead) abort
  let [l:lead, _] = flog#args#SplitArg(a:arg_lead)

  let l:completions = g:flog_open_cmds + g:flog_open_cmd_modifiers

  " Add combined open commands
  for l:modifier in g:flog_open_cmd_modifiers
    for l:open_cmd in g:flog_open_cmds
      call add(l:completions, l:modifier . ' ' . l:open_cmd)
    endfor
  endfor

  let l:completions = flog#args#EscapeCompletions(l:lead, l:completions)

  return flog#args#FilterCompletions(a:arg_lead, l:completions)
endfunction

function! flog#cmd#flog#args#CompleteAuthor(arg_lead) abort
  if !flog#backend#IsGitBuf()
    return []
  endif

  let [l:lead, _] = flog#args#SplitArg(a:arg_lead)
  let l:completions = flog#git#GetAuthors()
  return flog#args#FilterCompletions(
        \ a:arg_lead,
        \ flog#args#EscapeCompletions(l:lead, l:completions)
        \ )
endfunction

function! flog#cmd#flog#args#CompleteLimit(arg_lead) abort
  let [l:lead, l:limit] = flog#args#SplitArg(a:arg_lead)

  let [l:range, l:path] = flog#args#SplitGitLimitArg(l:limit)
  if l:range !~# ':$'
    return []
  endif
  let l:path = flog#args#UnescapeArg(l:path)

  let l:completions = getcompletion(l:path, 'file')
  let l:completions = flog#args#EscapeCompletions(l:lead . l:range, l:completions)
  return flog#args#FilterCompletions(a:arg_lead, l:completions)
endfunction

function! flog#cmd#flog#args#CompleteRev(arg_lead) abort
  if !flog#backend#IsGitBuf()
    return []
  endif
  let [l:lead, _] = flog#args#SplitArg(a:arg_lead)

  let l:refs = flog#git#GetRefs()

  let l:completions = flog#args#EscapeCompletions(l:lead, l:refs)
  return flog#args#FilterCompletions(a:arg_lead, l:completions)
endfunction

function! flog#cmd#flog#args#CompletePath(arg_lead) abort
  let [l:lead, l:path] = flog#args#SplitArg(a:arg_lead)
  let l:path = flog#args#UnescapeArg(l:path)

  let l:files = getcompletion(l:path, 'file')

  let l:completions = flog#args#EscapeCompletions(l:lead, l:files)
  return flog#args#FilterCompletions(a:arg_lead, l:completions)
endfunction

function! flog#cmd#flog#args#CompleteOrder(arg_lead) abort
  let [l:lead, _] = flog#args#SplitArg(a:arg_lead)

  let l:order_types = []
  for l:order_type in g:flog_order_types
    call add(l:order_types, l:order_type.name)
  endfor

  let l:completions = flog#args#EscapeCompletions(l:lead, l:order_types)
  return flog#args#FilterCompletions(a:arg_lead, l:completions)
endfunction

function! flog#cmd#flog#args#Complete(arg_lead, cmd_line, cursor_pos) abort
  if a:cmd_line[ : a:cursor_pos] =~# ' -- '
    return []
  endif

  let l:default_completion = [
        \ '-all ',
        \ '--no-all ',
        \ '-author=',
        \ '-auto-update ',
        \ '-no-auto-update ',
        \ '-bisect ',
        \ '-no-bisect ',
        \ '-date=',
        \ '-default-collapsed ',
        \ '-default-expanded ',
        \ '-first-parent ',
        \ '-no-first-parent ',
        \ '-format=',
        \ '-graph ',
        \ '-no-graph ',
        \ '-limit=',
        \ '-max-count=',
        \ '-merges ',
        \ '-no-merges ',
        \ '-open-cmd=',
        \ '-patch ',
        \ '-no-patch ',
        \ '-patch-search=',
        \ '-patch-grep=',
        \ '-path=',
        \ '-raw-args=',
        \ '-reflog ',
        \ '-no-reflog ',
        \ '-related',
        \ '-no-related',
        \ '-rev=',
        \ '-reverse ',
        \ '-no-reverse ',
        \ '-search=',
        \ '-grep=',
        \ '-skip=',
        \ '-order=',
        \ '-sort=',
        \ ]

  if a:arg_lead ==# ''
    return flog#args#FilterCompletions(a:arg_lead, l:default_completion)
  elseif a:arg_lead =~# '^-format='
    return flog#cmd#flog#args#CompleteFormat(a:arg_lead)
  elseif a:arg_lead =~# '^-date='
    return flog#cmd#flog#args#CompleteDate(a:arg_lead)
  elseif a:arg_lead =~# '^-open-cmd='
    return flog#cmd#flog#args#CompleteOpenCmd(a:arg_lead)
  elseif a:arg_lead =~# '^-\(patch-\)\?\(search\|grep\)='
    return []
  elseif a:arg_lead =~# '^-author='
    return flog#cmd#flog#args#CompleteAuthor(a:arg_lead)
  elseif a:arg_lead =~# '^-limit='
    return flog#cmd#flog#args#CompleteLimit(a:arg_lead)
  elseif a:arg_lead =~# '^-rev='
    return flog#cmd#flog#args#CompleteRev(a:arg_lead)
  elseif a:arg_lead =~# '^-path='
    return flog#cmd#flog#args#CompletePath(a:arg_lead)
  elseif a:arg_lead =~# '^-\(order\|sort\)='
    return flog#cmd#flog#args#CompleteOrder(a:arg_lead)
  endif
  return flog#args#FilterCompletions(a:arg_lead, l:default_completion)
endfunction

" Get arguments for a range passed to Flog.
function! flog#cmd#flog#args#GetRangeArgs(range, line1, line2) abort
  let l:limit = ''

  if a:range ==# 1
    if a:line1 ==# 0
      let l:limit = '1,'
    else
      let l:limit = a:line1 . ',' . a:line2
    endif
  elseif a:range ==# 2
    let l:limit = a:line1 . ',' . a:line2
  endif

  if l:limit !=# ''
    return ['-limit=' . l:limit . ':' . expand('%:p')]
  endif

  return []
endfunction
