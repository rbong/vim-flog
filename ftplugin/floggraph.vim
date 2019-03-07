silent setlocal nomodifiable
      \ readonly
      \ noswapfile
      \ nobuflisted
      \ nowrap
      \ buftype=nofile
      \ bufhidden=wipe

" Bindings {{{

if !hasmapto('<Plug>Flogvsplitcommitright')
  map <buffer> <CR> <Plug>Flogvsplitcommitright
endif
nnoremap <buffer> <silent> <Plug>Flogvsplitcommitright :vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>Flogvnextcommitright')
  map <buffer> <C-N> <Plug>Flogvnextcommitright
endif
if !hasmapto('<Plug>Flogvprevcommitright')
  map <buffer> <C-P> <Plug>Flogvprevcommitright
endif
nnoremap <buffer> <silent> <Plug>Flogvnextcommitright :<C-U>call flog#next_commit() \| call flog#preview_commit('vertical belowright Gsplit')<CR>
nnoremap <buffer> <silent> <Plug>Flogvprevcommitright :<C-U>call flog#previous_commit() \| call flog#preview_commit('vertical belowright Gsplit')<CR>

if !hasmapto('<Plug>Flogtoggleall')
  map <buffer> a <Plug>Flogtoggleall
endif
nnoremap <buffer> <silent> <Plug>Flogtoggleall :call flog#toggle_all_refs_option()<CR>

if !hasmapto('<Plug>Flogtogglebisect')
  map <buffer> gb <Plug>Flogtogglebisect
endif
nnoremap <buffer> <silent> <Plug>Flogtogglebisect :call flog#toggle_bisect_option()<CR>

if !hasmapto('<Plug>Flogtogglenomerges')
  map <buffer> gm <Plug>Flogtogglenomerges
endif
nnoremap <buffer> <silent> <Plug>Flogtogglenomerges :call flog#toggle_no_merges_option()<CR>

if !hasmapto('<Plug>Flogupdate')
  map <buffer> u <Plug>Flogupdate
endif
nnoremap <buffer> <silent> <Plug>Flogupdate :call flog#populate_graph_buffer()<CR>

if !hasmapto('<Plug>Floggit')
  map <buffer> git <Plug>Floggit
endif
nnoremap <buffer> <silent> <Plug>Floggit :Floggit
vnoremap <buffer> <silent> <Plug>Floggit :Floggit

if !hasmapto('<Plug>Flogyank')
  map <buffer> y<C-G> <Plug>Flogyank
endif
nnoremap <buffer><silent> <Plug>Flogyank :call flog#copy_commits()<CR>
vnoremap <buffer><silent> <Plug>Flogyank :call flog#copy_commits(1)<CR>

if !hasmapto('<Plug>Flogquit')
  map <buffer> ZZ <Plug>Flogquit
endif
nnoremap <buffer> <Plug>Flogquit :call flog#quit()<CR>

" }}}

" Commands {{{

command! -buffer Flogsplitcommit call flog#preview_commit('<mods> Gsplit')

command! -buffer -range -bang -complete=custom,flog#complete_git -nargs=* Floggit call flog#git('<mods>', '<bang>', <q-args>)

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
