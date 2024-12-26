" Errors

let g:flog_shell_error = 'flog: encountered shell error'
let g:flog_missing_state = 'flog: could not find state'
let g:flog_not_a_fugitive_buffer = 'flog: not a fugitive buffer'
let g:flog_not_a_flog_buffer = 'flog: not a flog buffer'
let g:flog_no_commits_found = 'flog: error parsing commits: no commits found'
let g:flog_unsupported_argument = 'flog: unrecognized argument'
let g:flog_unsupported_exec_format_item = 'flog: unrecognized exec format item'
let g:flog_invalid_commit_mark = 'flog: invalid commit mark'
let g:flog_reverse_requires_no_graph = 'flog: -reverse requires -no-graph'
let g:flog_lua_not_found = 'flog: Lua not found'

" Settings

if !has_key(g:, 'flog_write_commit_graph')
  let g:flog_write_commit_graph = v:true
endif

if !has_key(g:, 'flog_write_commit_graph_args')
  let g:flog_write_commit_graph_args = ['--reachable', '--progress']
endif

if !has_key(g:, 'flog_enable_status')
  let g:flog_enable_status = v:false
endif

if !has_key(g:, 'flog_enable_extended_chars')
  let g:flog_enable_extended_chars = v:false
endif

if !has_key(g:, 'flog_enable_extra_padding')
  let g:flog_enable_extra_padding = v:false
endif

if !has_key(g:, 'flog_enable_dynamic_branch_hl')
  let g:flog_enable_dynamic_branch_hl = v:true
endif

if !has_key(g:, 'flog_enable_dynamic_commit_hl')
  let g:flog_enable_dynamic_commit_hl = v:false
endif

if !has_key(g:, 'flog_check_lua_version')
  let g:flog_check_lua_version = v:true
endif

if !has_key(g:, 'flog_get_author_args')
  let g:flog_get_author_args = ['--all', '--no-merges', '--max-count=100000']
endif

if !has_key(g:, 'flog_commit_start_token')
  let g:flog_commit_start_token = '__START'
endif

if !has_key(g:, 'flog_order_types')
  let g:flog_order_types = [
        \ { 'name': 'date', 'args': '--date-order' },
        \ { 'name': 'author', 'args': '--author-date-order' },
        \ { 'name': 'topo', 'args': '--topo-order' },
        \ ]
endif

" Data

let g:flog_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

let g:flog_lua_dir = g:flog_root_dir .. '/lua'

let g:flog_format_specifiers = [
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

let g:flog_date_formats = [
      \ 'human',
      \ 'local',
      \ 'relative',
      \ 'short',
      \ 'iso', 
      \ 'iso-strict',
      \ 'rfc',
      \ 'format:',
      \ ]

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

" Commands

command! -range=0 -complete=customlist,flog#cmd#flog#args#Complete -nargs=* Flog call flog#cmd#Flog(flog#cmd#flog#args#GetRangeArgs(<range>, <line1>, <line2>) + [<f-args>])
command! -range=0 -complete=customlist,flog#cmd#flog#args#Complete -nargs=* Flogsplit call flog#cmd#Flog(flog#cmd#flog#args#GetRangeArgs(<range>, <line1>, <line2>) + ['-open-cmd=<mods> split', <f-args>])
cnoreabbrev Flogsp Flogsplit
command! -range -bang -complete=customlist,flog#cmd#floggit#args#Complete -nargs=* Floggit call flog#cmd#Floggit('<mods>', <q-args>, '<bang>')
