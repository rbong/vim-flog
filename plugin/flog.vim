" Plugin boilerplate {{{

if exists('g:loaded_flog')
  finish
endif

let g:loaded_flog = 1

" }}}

" Global state {{{

let g:flog_instance_counter = 0

" }}}

" Open command arg data {{{

let g:flog_open_cmds = [
      \ 'edit',
      \ 'split',
      \ 'vsplit',
      \ 'new',
      \ 'vnew',
      \ 'tabedit',
      \ 'tabnew',
      \ ]

let g:flog_open_cmd_modifiers = [
      \ 'aboveleft',
      \ 'belowright',
      \ 'botright',
      \ 'confirm',
      \ 'leftabove',
      \ 'rightbelow',
      \ 'silent',
      \ 'tab',
      \ 'topleft',
      \ 'verbose',
      \ 'vertical',
      \ ]

" }}}

" Log command build data {{{

" used to delineate format specifiers used to retrieve commit data
let g:flog_format_start = '__FSTART__'
let g:flog_data_start = '__DSTART__'

" }}}

" Sorting type data {{{

let g:flog_sort_types = [
      \ { 'name': 'date', 'args': '--date-order' },
      \ { 'name': 'author', 'args': '--author-date-order' },
      \ { 'name': 'topo', 'args': '--topo-order' },
      \ ]

" }}}

" Completion data {{{

let g:flog_default_completion = [
      \ '-all ',
      \ '-author=',
      \ '-bisect ',
      \ '-date=',
      \ '-format=',
      \ '-limit=',
      \ '-max-count=',
      \ '-no-graph',
      \ '-no-merges',
      \ '-no-patch',
      \ '-open-cmd=',
      \ '-patch-search=',
      \ '-path=',
      \ '-raw-args=',
      \ '-reflog ',
      \ '-rev=',
      \ '-reverse',
      \ '-search=',
      \ '-skip=',
      \ '-sort=',
      \ ]

let g:flog_date_formats = [
      \ 'iso8601', 
      \ 'short',
      \ ]

" Format specifier data {{{

function! s:LongSpecifierPattern()
  let l:long_specifiers = []
  for l:specifier in g:flog_long_specifiers
    for i in range(1, len(l:specifier) - 2)
      let l:long_specifiers += [specifier[:i]]
    endfor
  endfor
  return '\(' . join(l:long_specifiers, '\|') . '\)'
endfunction

let g:flog_eat_specifier_pattern = '^\(%.\|[^%]\)*'
let g:flog_specifier_partial_char = '[acgGC(]' 
let g:flog_specifier_hex_start = 'x[0-9]\?'
let g:flog_specifier_bracket_start = '\([Cw<>]\|<|\|>>\|><\)'
let g:flog_specifier_partial_bracket = '\(\([Cw<>]\|<|\|>>\|><\)(\|(trailers:\)[^\)]*'
let g:flog_long_specifiers = [
      \ 'Cred',
      \ 'Cgreen',
      \ 'Cblue',
      \ 'Creset',
      \ '(trailers:',
      \ '(trailers)',
      \ ]
let g:flog_specifier_long_pattern = s:LongSpecifierPattern()
let g:flog_completable_partials = [
      \ g:flog_specifier_partial_char,
      \ g:flog_specifier_bracket_start,
      \ g:flog_specifier_long_pattern,
      \ ]
let g:flog_noncompletable_partials = [
      \ g:flog_specifier_hex_start,
      \ g:flog_specifier_partial_bracket,
      \ ]
let g:flog_completable_specifier_pattern = '\(' . join(g:flog_completable_partials, '\|') . '\)'
let g:flog_noncompletable_specifier_pattern = '\(' . join(g:flog_noncompletable_partials, '\|') . '\)'

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

" }}}

" Errors {{{

let g:flog_shell_error = 'flog: encountered shell error'
let g:flog_missing_state = 'flog: could not find state'
let g:flog_not_a_fugitive_buffer = 'flog: not a fugitive buffer'
let g:flog_no_commits = 'flog: error parsing commits: no commits found'
let g:flog_missing_commit_start = 'flog: error parsing commits: could not find start of commit'
let g:flog_unsupported_argument = 'flog: unrecognized argument'
let g:flog_unsupported_command_format_item = 'flog: unrecognized command format item'
let g:flog_invalid_mark = 'flog: invalid mark'

" }}}

" Deprecation warnings {{{

let g:flog_shown_deprecation_warnings = {}

" }}}

" Git command data {{{

let g:flog_git_command_spec = {
      \ 'bisect': {
            \ 'subcommands': [
                  \ 'start',
                  \ 'new',
                  \ 'bad',
                  \ 'old',
                  \ 'terms',
                  \ 'skip',
                  \ 'reset',
                  \ 'replay',
                  \ 'run',
                  \ 'help',
                  \ ],
            \ },
      \ 'rebase': {
            \ 'subcommands': [
                  \ '--continue',
                  \ '--skip',
                  \ '--abort',
                  \ '--quit',
                  \ '--show-current-patch',
                  \ ],
            \ 'options': [
                  \ '-i',
                  \ '--interactive',
                  \ '--autosquash',
                  \ '--edit-todo',
                  \ '--exec',
                  \ ],
            \ },
      \ 'merge': {
            \ 'subcommands': [
                  \ '--continue',
                  \ '--abort',
                  \ '--quit',
                  \ ],
            \ 'options': [
                  \ '--squash',
                  \ '--edit',
                  \ '--no-edit',
                  \ '--no-verify',
                  \ '-m',
                  \ '-F',
                  \ ],
            \ },
      \ 'cherry-pick': {
            \ 'subcommands': [
                  \ '--continue',
                  \ '--skip',
                  \ '--abort',
                  \ '--quit',
                  \ ],
            \ },
      \ 'push': {
            \ 'options': [
                  \ '--all',
                  \ '--mirror',
                  \ '--tags',
                  \ '--atomic',
                  \ '--no-atomic',
                  \ '--dry-run',
                  \ '--force',
                  \ '--delete',
                  \ '--prune',
                  \ '--verbose',
                  \ '--upstream',
                  \ '--no-verify',
                  \ ],
            \ },
      \ }

" }}}

" Commands {{{

command! -range -bang -complete=customlist,flog#complete_git -nargs=* Floggit call flog#run_raw_command('<mods> Git ' . <q-args>, 1, 1, !empty('<bang>'))

command! -range=0 -complete=customlist,flog#complete -nargs=* Flog call flog#open((<count> ? ['-limit=<line1>,<line2>:' . expand('%:p')] : []) + [<f-args>])

command! -range=0 -complete=customlist,flog#complete -nargs=* Flogsplit call flog#open((<count> ? ['-limit=<line1>,<line2>:' . expand('%:p')] : []) + ['-open-cmd=<mods> split', <f-args>])

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
