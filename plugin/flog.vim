vim9script

# Errors

g:flog_shell_error = 'flog: encountered shell error'
g:flog_missing_state = 'flog: could not find state'
g:flog_not_a_fugitive_buffer = 'flog: not a fugitive buffer'
g:flog_no_commits_found = 'flog: error parsing commits: no commits found'
g:flog_unsupported_argument = 'flog: unrecognized argument'
g:flog_sort_type_not_found = 'flog: sort type not found'
g:flog_graph_draw_error = 'flog: internal error drawing graph'
g:flog_invalid_commit_mark = 'flog: invalid commit mark'

# Options

g:flog_get_author_args = '--all --no-merges --max-count=100000'

g:flog_commit_start_token = '__START'

g:flog_sort_types = [
  { name: 'date', args: '--date-order' },
  { name: 'author', args: '--author-date-order' },
  { name: 'topo', args: '--topo-order' },
  ]

# Data

g:flog_format_specifiers = [
  '%H',
  '%h',
  '%T',
  '%t',
  '%P',
  '%p',
  '%an',
  '%aN',
  '%ae',
  '%aE',
  '%ad',
  '%aD',
  '%ar',
  '%at',
  '%ai',
  '%aI',
  '%cn',
  '%cN',
  '%ce',
  '%cE',
  '%cd',
  '%cD',
  '%cr',
  '%ct',
  '%ci',
  '%cI',
  '%d',
  '%D',
  '%e',
  '%s',
  '%f',
  '%b',
  '%B',
  '%N',
  '%GG',
  '%G?',
  '%GS',
  '%GK',
  '%gD',
  '%gd',
  '%gn',
  '%gN',
  '%ge',
  '%gE',
  '%gs',
  '%m',
  '%n',
  '%%',
  '%x00',
  '%w(',
  '%<(',
  '%<|(',
  '%>(',
  '%>>(',
  '%><(',
  '%(trailers:',
  '%(trailers)',
  ]

g:flog_date_formats = [
  'iso8601', 
  'short',
  ]

g:flog_open_cmds = [
  'edit',
  'split',
  'vsplit',
  'new',
  'vnew',
  'tabedit',
  'tabnew',
  ]

g:flog_open_cmd_modifiers = [
  'aboveleft',
  'belowright',
  'botright',
  'confirm',
  'leftabove',
  'rightbelow',
  'silent',
  'tab',
  'topleft',
  'verbose',
  'vertical',
  ]

# Commands

command! -range=0 -complete=customlist,flog#cmd#flog#args#complete -nargs=* Flog call flog#cmd#flog((<count> > 1 ? ['-limit=<line1>,<line2>:' .. expand('%:p')] : []) + [<f-args>])
command! -range=0 -complete=customlist,flog#cmd#flog#args#complete -nargs=* Flogsplit call flog#cmd#flog((<count> > 1 ? ['-limit=<line1>,<line2>:' .. expand('%:p')] : []) + ['-open-cmd=<mods> split', <f-args>])
