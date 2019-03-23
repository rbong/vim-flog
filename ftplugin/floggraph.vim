silent setlocal nomodifiable
      \ readonly
      \ noswapfile
      \ nobuflisted
      \ nowrap
      \ buftype=nofile
      \ bufhidden=wipe

" Bindings {{{

if !g:flog_has_shown_deprecated_mapping_spelling_warning
  for flog_deprecated_mapping in [
        \ '<Plug>Floggit',
        \ '<Plug>Floghelp',
        \ '<Plug>Flogquit',
        \ '<Plug>Flogtoggleall',
        \ '<Plug>Flogtogglebisect',
        \ '<Plug>Flogtogglenomerges',
        \ '<Plug>Flogupdate',
        \ '<Plug>Flogvnextcommitright',
        \ '<Plug>Flogvprevcommitright',
        \ '<Plug>Flogvsplitcommitright',
        \ '<Plug>Flogyank',
        \ ]
    if hasmapto(flog_deprecated_mapping)
      echoerr 'Waring: using deprecated mapping ' . flog_deprecated_mapping
      echoerr 'Please capitalize flog mappings in the following way: <Plug>Flogmapping to <Plug>FlogMapping'
      let g:flog_has_shown_deprecated_mapping_spelling_warning = 1
      break
    endif
  endfor
endif

if !hasmapto('<Plug>FlogVsplitcommitright')
  nmap <buffer> <CR> <Plug>FlogVsplitcommitright
endif
nnoremap <buffer> <silent> <Plug>FlogVsplitcommitright :vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>FlogVnextcommitright')
  nmap <buffer> <C-N> <Plug>FlogVnextcommitright
endif
if !hasmapto('<Plug>FlogVprevcommitright')
  nmap <buffer> <C-P> <Plug>FlogVprevcommitright
endif
nnoremap <buffer> <silent> <Plug>FlogVnextcommitright :<C-U>call flog#next_commit() \| vertical belowright Flogsplitcommit<CR>
nnoremap <buffer> <silent> <Plug>FlogVprevcommitright :<C-U>call flog#previous_commit() \| vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>FlogToggleall')
  nmap <buffer> a <Plug>FlogToggleall
endif
nnoremap <buffer> <silent> <Plug>FlogToggleall :call flog#toggle_all_refs_option()<CR>

if !hasmapto('<Plug>FlogTogglebisect')
  nmap <buffer> gb <Plug>FlogTogglebisect
endif
nnoremap <buffer> <silent> <Plug>FlogTogglebisect :call flog#toggle_bisect_option()<CR>

if !hasmapto('<Plug>FlogTogglenomerges')
  nmap <buffer> gm <Plug>FlogTogglenomerges
endif
nnoremap <buffer> <silent> <Plug>FlogTogglenomerges :call flog#toggle_no_merges_option()<CR>

if !hasmapto('<Plug>FlogUpdate')
  nmap <buffer> u <Plug>FlogUpdate
endif
nnoremap <buffer> <silent> <Plug>FlogUpdate :call flog#populate_graph_buffer()<CR>

if !hasmapto('<Plug>FlogGit')
  nmap <buffer> git <Plug>FlogGit
  vmap <buffer> git <Plug>FlogGit
endif
nnoremap <buffer> <silent> <Plug>FlogGit :Floggit
vnoremap <buffer> <silent> <Plug>FlogGit :Floggit

if !hasmapto('<Plug>FlogYank')
  nmap <buffer> y<C-G> <Plug>FlogYank
  vmap <buffer> y<C-G> <Plug>FlogYank
endif
nnoremap <buffer> <silent> <Plug>FlogYank :call flog#copy_commits()<CR>
vnoremap <buffer> <silent> <Plug>FlogYank :call flog#copy_commits(1)<CR>

if !hasmapto('<Plug>FlogQuit')
  nmap <buffer> ZZ <Plug>FlogQuit
endif
nnoremap <buffer> <Plug>FlogQuit :call flog#quit()<CR>

if !hasmapto('<Plug>FlogHelp')
  nmap <buffer> g? <Plug>FlogHelp
endif
nnoremap <buffer> <Plug>FlogHelp :help flog-mappings<CR>

" }}}

" Commands {{{

command! -buffer Flogsplitcommit call flog#preview_commit('<mods> Gsplit')

command! -buffer -range -bang -complete=custom,flog#complete_git -nargs=* Floggit call flog#git('<mods>', '<bang>', <q-args>)

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
