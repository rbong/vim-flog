let g:flog_instance_counter = 0

" used to determine parts of the output window are graph lines
let g:flog_graph_branch_pattern = '[|\/\\ ]'

" Log command build data {{{

" used to delineate format specifiers used to retrieve commit data
let g:flog_format_start = '__FSTART__'
let g:flog_format_separator = '__FSEP__'
let g:flog_format_end = '__FEND__'
" used to delineate which part of the log to display to the user
let g:flog_display_commit_start = '__DSTART__'
let g:flog_display_commit_end = '__DEND__'
" information about specifiers for use with --pretty=format:*
let g:flog_format_specifiers = {
      \ 'short_commit_hash': '%h',
      \ 'ref_names_unwrapped': '%D',
      \ }
" the specifiers to use to retrieve data
let g:flog_log_data_format_specifiers = [
      \ 'ref_names_unwrapped',
      \ 'short_commit_hash',
      \ ]

" }}}

" Format specifier patterns {{{

let g:flog_eat_specifier_pattern = '^\(%.\|[^%]\)*'
let g:flog_specifier_partial_char = '[acgGC(]' 
let g:flog_specifier_partial_hex = 'x[0-9]\?'
let g:flog_specifier_partial_bracket_start = '\([Cw<>]\|<|\|>>\|><\)'
let g:flog_specifier_partial_bracket = '\(\([Cw<>]\|<|\|>>\|><\)(\|(trailers:\)[^\)]*'
let g:flog_long_specifiers = [
      \ 'Cred',
      \ 'Cgreen',
      \ 'Cblue',
      \ 'Creset',
      \ '(trailers:',
      \ '(trailers)',
      \ ]
let long_specifiers = []
for specifier in g:flog_long_specifiers
  for i in range(1, len(specifier) - 2)
    let long_specifiers += [specifier[:i]]
  endfor
endfor
let g:flog_specifier_partial_long = '\(' . join(long_specifiers, '\|') . '\)'
unlet! long_specifiers specifier
let g:flog_completable_partials = [
      \ g:flog_specifier_partial_char,
      \ g:flog_specifier_partial_bracket_start,
      \ g:flog_specifier_partial_long,
      \ ]
let g:flog_noncompletable_partials = [
      \ g:flog_specifier_partial_hex,
      \ g:flog_specifier_partial_bracket,
      \ ]
let g:flog_completable_partial_pattern = '\(' . join(g:flog_completable_partials, '\|') . '\)'
let g:flog_noncompletable_partial_pattern = '\(' . join(g:flog_noncompletable_partials, '\|') . '\)'

let g:flog_default_completion = "\n-all \n-format=\n-open-cmd=\n-path=\n-additional-args="
let g:flog_completion_specifiers = [
      \ '%H',
      \ '%h',
      \ '%T',
      \ '%t',
      \ '%P',
      \ '%p',
      \ '%an',
      \ '%aN',
      \ '%ae',
      \ '%aE',
      \ '%ad',
      \ '%aD',
      \ '%ar',
      \ '%at',
      \ '%ai',
      \ '%aI',
      \ '%cn',
      \ '%cN',
      \ '%ce',
      \ '%cE',
      \ '%cd',
      \ '%cD',
      \ '%cr',
      \ '%ct',
      \ '%ci',
      \ '%cI',
      \ '%d',
      \ '%D',
      \ '%e',
      \ '%s',
      \ '%f',
      \ '%b',
      \ '%B',
      \ '%N',
      \ '%GG',
      \ '%G?',
      \ '%GS',
      \ '%GK',
      \ '%gD',
      \ '%gd',
      \ '%gn',
      \ '%gN',
      \ '%ge',
      \ '%gE',
      \ '%gs',
      \ '%Cred',
      \ '%Cgreen',
      \ '%Cblue',
      \ '%Creset',
      \ '%C(',
      \ '%m',
      \ '%n',
      \ '%%',
      \ '%x00',
      \ '%w(',
      \ '%<(',
      \ '%<|(',
      \ '%>(',
      \ '%>>(',
      \ '%><(',
      \ '%(trailers:',
      \ '%(trailers)',
      \ ]

" }}}

" Errors {{{

let g:flog_missing_state = 'flog: could not find state'
let g:flog_not_a_fugitive_buffer = 'flog: not a fugitive buffer'
let g:flog_no_log_output = 'flog: error parsing commits: no git output'
let g:flog_no_commits = 'flog: error parsing commits: no commits found'
let g:flog_missing_commit_start = 'flog: error parsing commits: could not find start of commit'
let g:flog_unsupported_argument = 'flog: unrecognized argument'

" }}}

" Commands {{{

command! -complete=custom,flog#complete -nargs=* Flog call flog#open([<f-args>])
command! -complete=custom,flog#complete -nargs=* Flogsplit call flog#open(['-open-cmd=<mods> split', <f-args>])

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
