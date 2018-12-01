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
nnoremap <buffer> <silent> <Plug>Flogvnextcommitright :<C-U>vertical belowright Flognextcommit<CR>
nnoremap <buffer> <silent> <Plug>Flogvprevcommitright :<C-U>vertical belowright Flogprevcommit<CR>

if !hasmapto('<Plug>Flogtoggleall')
  map <buffer> a <Plug>Flogtoggleall
endif
nnoremap <buffer> <silent> <Plug>Flogtoggleall :Flogtoggleall<CR>

if !hasmapto('<Plug>Flogupdate')
  map <buffer> u <Plug>Flogupdate
endif
nnoremap <buffer> <silent> <Plug>Flogupdate :Flogupdate<CR>

if !hasmapto('<Plug>Flogquit')
  map <buffer> ZZ <Plug>Flogquit
endif
nnoremap <buffer> <silent> <Plug>Flogquit :Flogquit<CR>

" }}}

" Commands {{{

command! -buffer Flogsplitcommit call flog#preview_commit('<mods> Gsplit')

command! -buffer -count Flognextcommit call flog#next_commit() | call flog#preview_commit('<mods> Gsplit')
command! -buffer -count Flogprevcommit call flog#previous_commit() | call flog#preview_commit('<mods> Gsplit')

command! -buffer Flogtoggleall call flog#toggle_all_refs_option()

command! -buffer Flogupdate call flog#populate_graph_buffer()

command! -buffer Flogquit call flog#quit()

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
