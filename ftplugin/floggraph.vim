silent setlocal nomodifiable
      \ readonly
      \ noswapfile
      \ nobuflisted
      \ nonumber
      \ norelativenumber
      \ nowrap
      \ buftype=nofile
      \ bufhidden=wipe

" Bindings {{{

if !hasmapto('<Plug>Flogvsplitright')
  map <buffer> <CR> <Plug>Flogvsplitright
endif
nnoremap <buffer> <silent> <Plug>Flogvsplitright :vertical belowright Flogsplit<CR>

if !hasmapto('<Plug>Flogvnextcommitright')
  map <buffer> <C-N> <Plug>Flogvnextcommitright
endif
if !hasmapto('<Plug>Flogvprevcommitright')
  map <buffer> <C-P> <Plug>Flogvprevcommitright
endif
nnoremap <buffer> <silent> <Plug>Flogvnextcommitright :<C-U>vertical belowright Flognextcommit<CR>
nnoremap <buffer> <silent> <Plug>Flogvprevcommitright :<C-U>vertical belowright Flogprevcommit<CR>

if !hasmapto('<Plug>Flogquit')
  map <buffer> ZZ <Plug>Flogquit
endif
nnoremap <buffer> <silent> <Plug>Flogquit :Flogquit<CR>

" }}}

" Commands {{{

command! -buffer Flogsplit call flog#open_commit('<mods> Gsplit')

command! -buffer -count Flognextcommit call flog#next_commit() | call flog#open_commit('<mods> Gsplit')
command! -buffer -count Flogprevcommit call flog#previous_commit() | call flog#open_commit('<mods> Gsplit')

command! -buffer Flogquit call flog#quit()

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
