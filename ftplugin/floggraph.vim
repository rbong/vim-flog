silent setlocal nomodifiable
      \ readonly
      \ noswapfile
      \ nobuflisted
      \ nowrap
      \ buftype=nofile
      \ bufhidden=wipe
      \ cursorline
      \ nomodeline

" Mappings {{{

" Misc. mappings {{{

if !hasmapto('<Plug>(FlogHelp)')
  nmap <buffer> g? <Plug>(FlogHelp)
endif
nnoremap <buffer> <silent> <Plug>(FlogHelp) :help flog-mappings<CR>

if !hasmapto('<Plug>(FlogVSplitCommitRight)')
  nmap <buffer> <CR> <Plug>(FlogVSplitCommitRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVSplitCommitRight) :vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>(FlogVSplitCommitPathsRight)')
  nmap <buffer> <Tab> <Plug>(FlogVSplitCommitPathsRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVSplitCommitPathsRight) :<C-U>call flog#run_tmp_command('vertical belowright Git show %h -- %p')<CR>

if !hasmapto('<Plug>(FlogVDiffSplitRight)')
  nmap <buffer> dd <Plug>(FlogVDiffSplitRight)
  vmap <buffer> dd <Plug>(FlogVDiffSplitRight)
  nmap <buffer> dv <Plug>(FlogVDiffSplitRight)
  vmap <buffer> dv <Plug>(FlogVDiffSplitRight)
endif

if !hasmapto('<Plug>(FlogVDiffSplitPathsRight)')
  nmap <buffer> dp <Plug>(FlogVDiffSplitPathsRight)
  vmap <buffer> dp <Plug>(FlogVDiffSplitPathsRight)
  nmap <buffer> DD <Plug>(FlogVDiffSplitPathsRight)
  vmap <buffer> DD <Plug>(FlogVDiffSplitPathsRight)
  nmap <buffer> DV <Plug>(FlogVDiffSplitPathsRight)
  vmap <buffer> DV <Plug>(FlogVDiffSplitPathsRight)
endif

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitRight) :<C-U>call flog#run_tmp_command('vertical belowright Git diff HEAD %h')<CR>
vnoremap <buffer> <silent> <Plug>(FlogVDiffSplitRight) :<C-U>call flog#run_tmp_command("vertical belowright Git diff %(h'>) %(h'<)")<CR>

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitPathsRight) :<C-U>call flog#run_tmp_command('vertical belowright Git diff HEAD %h -- %p')<CR>
vnoremap <buffer> <silent> <Plug>(FlogVDiffSplitPathsRight) :<C-U>call flog#run_tmp_command("vertical belowright Git diff HEAD %(h'<) %(h'>) -- %p")<CR>

if !hasmapto('<Plug>(FlogVDiffSplitLastCommitRight)')
  nmap <buffer> d! <Plug>(FlogVDiffSplitLastCommitRight)
endif

if !hasmapto('<Plug>(FlogVDiffSplitLastCommitPathsRight)')
  nmap <buffer> D! <Plug>(FlogVDiffSplitLastCommitPathsRight)
endif

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitLastCommitRight) :<C-U> call flog#run_tmp_command("vertical belowright Git diff %(h'!) %H")<CR>

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitLastCommitPathsRight) :<C-U> call flog#run_tmp_command("vertical belowright Git diff %(h'!) %H -- %p")<CR>

if !hasmapto('<Plug>(FlogCloseTmpWin)')
  nmap <buffer> dq <Plug>(FlogCloseTmpWin)
endif

nnoremap <buffer> <silent> <Plug>(FlogCloseTmpWin) :<C-U>call flog#close_tmp_win()<CR>

if !hasmapto('<Plug>(FlogYank)')
  nmap <buffer> y<C-G> <Plug>(FlogYank)
  vmap <buffer> y<C-G> <Plug>(FlogYank)
endif
nnoremap <buffer> <silent> <Plug>(FlogYank) :call flog#copy_commits()<CR>
vnoremap <buffer> <silent> <Plug>(FlogYank) :call flog#copy_commits(1)<CR>

if !hasmapto('<Plug>(FlogGit)')
  nmap <buffer> git <Plug>(FlogGit)
  vmap <buffer> git <Plug>(FlogGit)
endif
nnoremap <buffer> <Plug>(FlogGit) :Floggit
vnoremap <buffer> <Plug>(FlogGit) :Floggit

if !hasmapto('<Plug>(FlogQuit)')
  nmap <buffer> ZZ <Plug>(FlogQuit)
  nmap <buffer> gq <Plug>(FlogQuit)
endif
nnoremap <buffer> <silent> <Plug>(FlogQuit) :call flog#quit()<CR>

" }}}

" Navigation mappings {{{

if !hasmapto('<Plug>(FlogVNextCommitRight)')
  nmap <buffer> <C-N> <Plug>(FlogVNextCommitRight)
  nmap <buffer> ) <Plug>(FlogVNextCommitRight)
endif
if !hasmapto('<Plug>(FlogVPrevCommitRight)')
  nmap <buffer> <C-P> <Plug>(FlogVPrevCommitRight)
  nmap <buffer> ( <Plug>(FlogVPrevCommitRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVNextCommitRight) :<C-U>call flog#next_commit() \| vertical belowright Flogsplitcommit<CR>
nnoremap <buffer> <silent> <Plug>(FlogVPrevCommitRight) :<C-U>call flog#previous_commit() \| vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>(FlogVNextRefRight)')
  nmap <buffer> ]r <Plug>(FlogVNextRefRight)
endif
if !hasmapto('<Plug>(FlogVPrevRefRight)')
  nmap <buffer> [r <Plug>(FlogVPrevRefRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVNextRefRight) :<C-U>call flog#next_ref() \| vertical belowright Flogsplitcommit<CR>
nnoremap <buffer> <silent> <Plug>(FlogVPrevRefRight) :<C-U>call flog#previous_ref() \| vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>(FlogSkipAhead)')
  nmap <buffer> ]] <Plug>(FlogSkipAhead)
endif
nnoremap <buffer> <silent> <Plug>(FlogSkipAhead) :<C-U>call flog#change_skip_by_max_count(1 * max([v:count, 1]))<CR>

if !hasmapto('<Plug>(FlogSkipBack)')
  nmap <buffer> [[ <Plug>(FlogSkipBack)
endif
nnoremap <buffer> <silent> <Plug>(FlogSkipBack) :<C-U>call flog#change_skip_by_max_count(-1 * max([v:count, 1]))<CR>

if !hasmapto('<Plug>(FlogSetSkip)')
  nmap <buffer> go <Plug>(FlogSetSkip)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetSkip) :<C-U>call flog#set_skip_option(v:count)<CR>

" }}}

" Argument modifier mappings {{{

if !hasmapto('<Plug>(FlogToggleAll)')
  nmap <buffer> a <Plug>(FlogToggleAll)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleAll) :call flog#toggle_all_refs_option()<CR>

if !hasmapto('<Plug>(FlogToggleBisect)')
  nmap <buffer> gb <Plug>(FlogToggleBisect)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleBisect) :call flog#toggle_bisect_option()<CR>

if !hasmapto('<Plug>(FlogToggleNoMerges)')
  nmap <buffer> gm <Plug>(FlogToggleNoMerges)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleNoMerges) :call flog#toggle_no_merges_option()<CR>

if !hasmapto('<Plug>(FlogToggleReflog)')
  nmap <buffer> gr <Plug>(FlogToggleReflog)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleReflog) :call flog#toggle_reflog_option()<CR>

if !hasmapto('<Plug>(FlogToggleReverse)')
  nmap <buffer> gsr <Plug>(FlogToggleReverse)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleReverse) :call flog#toggle_reverse_option()<CR>

if !hasmapto('<Plug>(FlogToggleNoGraph)')
  nmap <buffer> gx <Plug>(FlogToggleNoGraph)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleNoGraph) :call flog#toggle_no_graph_option()<CR>

if !hasmapto('<Plug>(FlogToggleNoPatch)')
  nmap <buffer> gp <Plug>(FlogToggleNoPatch)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleNoPatch) :call flog#toggle_no_patch_option()<CR>

if !hasmapto('<Plug>(FlogUpdate)')
  nmap <buffer> u <Plug>(FlogUpdate)
endif
nnoremap <buffer> <silent> <Plug>(FlogUpdate) :call flog#populate_graph_buffer()<CR>

if !hasmapto('<Plug>(FlogSearch)')
  nmap <buffer> g/ <Plug>(FlogSearch)
endif
nnoremap <buffer> <Plug>(FlogSearch) :<C-U>Flogsetargs -search=

if !hasmapto('<Plug>(FlogPatchSearch)')
  nmap <buffer> g\ <Plug>(FlogPatchSearch)
endif
nnoremap <buffer> <Plug>(FlogPatchSearch) :<C-U>Flogsetargs -patch-search=

if !hasmapto('<Plug>(FlogCycleSort)')
  nmap <buffer> gss <Plug>(FlogCycleSort)
endif
nnoremap <buffer> <silent> <Plug>(FlogCycleSort) :call flog#cycle_sort_option()<CR>

if !hasmapto('<Plug>(FlogSortDate)')
  nmap <buffer> gsd <Plug>(FlogSortDate)
endif
nnoremap <buffer> <silent> <Plug>(FlogSortDate) :call flog#set_sort_option('date')<CR>

if !hasmapto('<Plug>(FlogSortAuthor)')
  nmap <buffer> gsa <Plug>(FlogSortAuthor)
endif
nnoremap <buffer> <silent> <Plug>(FlogSortAuthor) :call flog#set_sort_option('author')<CR>

if !hasmapto('<Plug>(FlogSortTopo)')
  nmap <buffer> gst <Plug>(FlogSortTopo)
endif
nnoremap <buffer> <silent> <Plug>(FlogSortTopo) :call flog#set_sort_option('topo')<CR>

" }}}

" Commit/branch mappings {{{

if !hasmapto('<Plug>(FlogFixup)')
  nmap <buffer> cf <Plug>(FlogFixup)
endif
if !hasmapto('<Plug>(FlogFixupRebase)')
  nmap <buffer> cF <Plug>(FlogFixupRebase)
endif
nnoremap <buffer> <silent> <Plug>(FlogFixup) :<C-U>call flog#run_command('Git commit --fixup=%H', 1, 1)<CR>
nnoremap <buffer> <silent> <Plug>(FlogFixupRebase) :<C-U>call flog#run_command('Git commit --fixup=%H \| Git -c sequence.editor=true rebase --interactive --autosquash %H^', 1, 1)<CR>

if !hasmapto('<Plug>(FlogSquash)')
  nmap <buffer> cs <Plug>(FlogSquash)
endif
if !hasmapto('<Plug>(FlogSquashRebase)')
  nmap <buffer> cS <Plug>(FlogSquashRebase)
endif
if !hasmapto('<Plug>(FlogSquashEdit)')
  nmap <buffer> cA <Plug>(FlogSquashEdit)
endif
nnoremap <buffer> <silent> <Plug>(FlogSquash) :<C-U>call flog#run_command('Git commit --no-edit --squash=%H', 1, 1)<CR>
nnoremap <buffer> <silent> <Plug>(FlogSquashRebase) :<C-U>call flog#run_command('Git commit --no-edit --squash=%H \| Git -c sequence.editor=true rebase --interactive --autosquash %H^', 1, 1)<CR>
nnoremap <buffer> <silent> <Plug>(FlogSquashEdit) :<C-U>call flog#run_command('Git commit --edit --squash=%H', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRevert)')
  nmap <buffer> crc <Plug>(FlogRevert)
  vmap <buffer> crc <Plug>(FlogRevert)
endif

if !hasmapto('<Plug>(FlogRevertNoEdit)')
  nmap <buffer> crn <Plug>(FlogRevertNoEdit)
  vmap <buffer> crn <Plug>(FlogRevertNoEdit)
endif

nnoremap <buffer> <silent> <Plug>(FlogRevert) :<C-U>call flog#run_command('Git revert %H', 1, 1)<CR>
vnoremap <buffer> <silent> <Plug>(FlogRevert) :<C-U>call flog#run_command("Git revert %(h'<)^..%(h'>)", 1, 1)<CR>

nnoremap <buffer> <silent> <Plug>(FlogRevertNoEdit) :<C-U>call flog#run_command('Git revert --no-edit %H', 1, 1)<CR>
vnoremap <buffer> <silent> <Plug>(FlogRevertNoEdit) :<C-U>call flog#run_command("Git revert --no-edit %(h'<)^..%(h'>)", 1, 1)<CR>

if !hasmapto('<Plug>(FlogCheckout)')
  nmap <buffer> coo <Plug>(FlogCheckout)
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckout) :<C-U>call flog#run_command('Git checkout %H', 0, 1)<CR>

if !hasmapto('<Plug>(FlogCheckoutBranch)')
  nmap <buffer> cob <Plug>(FlogCheckoutBranch)
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckoutBranch) :<C-U>call flog#run_command('Git checkout %b', 0, 1)<CR>

if !hasmapto('<Plug>(FlogCheckoutLocalBranch)')
  nmap <buffer> cot <Plug>(FlogCheckoutLocalBranch)
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckoutLocalBranch) :<C-U>call flog#run_command('Git checkout %l', 0, 1)<CR>

if !hasmapto('<Plug>(FlogGitCommit)')
  nmap <buffer> c<Space> <Plug>(FlogGitCommit)
  vmap <buffer> c<Space> <Plug>(FlogGitCommit)
endif
nnoremap <buffer> <Plug>(FlogGitCommit) :Floggit commti<Space>
vnoremap <buffer> <Plug>(FlogGitCommit) :Floggit commti<Space>

if !hasmapto('<Plug>(FlogGitRevert)')
  nmap <buffer> cr<Space> <Plug>(FlogGitRevert)
  vmap <buffer> cr<Space> <Plug>(FlogGitRevert)
endif
nnoremap <buffer> <Plug>(FlogGitRevert) :Floggit revert<Space>
vnoremap <buffer> <Plug>(FlogGitRevert) :Floggit revert<Space>

if !hasmapto('<Plug>(FlogGitMerge)')
  nmap <buffer> cm<Space> <Plug>(FlogGitMerge)
  vmap <buffer> cm<Space> <Plug>(FlogGitMerge)
endif
nnoremap <buffer> <Plug>(FlogGitMerge) :Floggit merge<Space>
vnoremap <buffer> <Plug>(FlogGitMerge) :Floggit merge<Space>

if !hasmapto('<Plug>(FlogGitCheckout)')
  nmap <buffer> co<Space> <Plug>(FlogGitCheckout)
  vmap <buffer> co<Space> <Plug>(FlogGitCheckout)
endif
nnoremap <buffer> <Plug>(FlogGitCheckout) :Floggit checkout<Space>
vnoremap <buffer> <Plug>(FlogGitCheckout) :Floggit checkout<Space>

if !hasmapto('<Plug>(FlogGitBranch)')
  nmap <buffer> cb<Space> <Plug>(FlogGitBranch)
  vmap <buffer> cb<Space> <Plug>(FlogGitBranch)
endif
nnoremap <buffer> <Plug>(FlogGitBranch) :Floggit branch<Space>
vnoremap <buffer> <Plug>(FlogGitBranch) :Floggit branch<Space>

" }}}

" Rebase mappings {{{

if !hasmapto('<Plug>(FlogRebaseInteractive)')
  nmap <buffer> ri <Plug>(FlogRebaseInteractive)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractive) :<C-U>call flog#run_command('Git rebase --interactive %H^', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveAutosquash)')
  nmap <buffer> rf <Plug>(FlogRebaseInteractiveAutosquash)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveAutosquash) :<C-U>call flog#run_command('Git -c sequence.editor=true rebase --interactive --autosquash %H^', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveUpstream)')
  nmap <buffer> ru <Plug>(FlogRebaseInteractiveUpstream)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveUpstream) :<C-U>call flog#run_command('Git rebase --interactive @{upstream}', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractivePush)')
  nmap <buffer> rp <Plug>(FlogRebaseInteractivePush)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractivePush) :<C-U>call flog#run_command('Git rebase --interactive @{push}', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseContinue)')
  nmap <buffer> rr <Plug>(FlogRebaseContinue)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseContinue) :<C-U>call flog#run_command('Git rebase --continue', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseSkip)')
  nmap <buffer> rs <Plug>(FlogRebaseSkip)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseSkip) :<C-U>call flog#run_command('Git rebase --skip', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseAbort)')
  nmap <buffer> ra <Plug>(FlogRebaseAbort)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseAbort) :<C-U>call flog#run_command('Git rebase --abort', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseEditTodo)')
  nmap <buffer> re <Plug>(FlogRebaseEditTodo)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseEditTodo) :<C-U>call flog#run_command('Git rebase --edit-todo', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveReword)')
  nmap <buffer> rw <Plug>(FlogRebaseInteractiveReword)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveReword) :<C-U>call flog#run_command('Git rebase --interactive %H^ \| s/^pick/reword/e', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveEdit)')
  nmap <buffer> rm <Plug>(FlogRebaseInteractiveEdit)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveEdit) :<C-U>call flog#run_command('Git rebase --interactive %H^ \| s/^pick/edit/e', 1, 1)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveDrop)')
  nmap <buffer> rd <Plug>(FlogRebaseInteractiveDrop)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveDrop) :<C-U>call flog#run_command('Git rebase --interactive %H^ \| s/^pick/drop/e', 1, 1)<CR>

if !hasmapto('<Plug>(FlogGitRebase)')
  nmap <buffer> r<Space> <Plug>(FlogGitRebase)
  vmap <buffer> r<Space> <Plug>(FlogGitRebase)
endif
nnoremap <buffer> <Plug>(FlogGitRebase) :Floggit rebase<Space>
vnoremap <buffer> <Plug>(FlogGitRebase) :Floggit rebase<Space>

" }}}

" Mark mappings {{{

if !hasmapto('<Plug>(FlogSetCommitMark)')
  nmap <buffer> m <Plug>(FlogSetCommitMark)
  vmap <buffer> m <Plug>(FlogSetCommitMark)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetCommitMark) :<C-U>call flog#set_commit_mark_at_line(nr2char(getchar()), '.')<CR>
vnoremap <buffer> <silent> <Plug>(FlogSetCommitMark) :<C-U>call flog#set_commit_mark_at_line(nr2char(getchar()), '.')<CR>

if !hasmapto('<Plug>(FlogJumpToCommitMark)')
  nmap <buffer> ' <Plug>(FlogJumpToCommitMark)
  vmap <buffer> ' <Plug>(FlogJumpToCommitMark)
endif
nnoremap <buffer> <silent> <Plug>(FlogJumpToCommitMark) :<C-U>call flog#jump_to_commit_mark(nr2char(getchar()))<CR>
vnoremap <buffer> <silent> <Plug>(FlogJumpToCommitMark) :<C-U>call flog#jump_to_commit_mark(nr2char(getchar()))<CR>

" }}}

" Deprecated plugin mappings {{{

call flog#deprecate_plugin_mapping('<Plug>Flogvsplitcommitright', '<Plug>(FlogVSplitCommitRight)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogVsplitcommitright', '<Plug>(FlogVSplitCommitRight)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogVnextcommitright', '<Plug>(FlogVNextCommitRight)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Flogvnextcommitright', '<Plug>(FlogVNextCommitRight)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogVprevcommitright', '<Plug>(FlogVPrevCommitRight)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Flogvprevcommitright', '<Plug>(FlogVPrevCommitRight)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogVnextrefright', '<Plug>(FlogVNextRefRight)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogVprevrefright', '<Plug>(FlogVPrevRefRight)', 'nmap')

call flog#deprecate_plugin_mapping('<Plug>FlogToggleall', '<Plug>(FlogToggleAll)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Flogtoggleall', '<Plug>(FlogToggleAll)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogTogglebisect', '<Plug>(FlogToggleBisect)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Flogtogglebisect', '<Plug>(FlogToggleBisect)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogTogglenomerges', '<Plug>(FlogToggleNoMerges)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Flogtogglenomerges', '<Plug>(FlogToggleNoMerges)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogTogglereflog', '<Plug>(FlogToggleReflog)', 'nmap')

call flog#deprecate_plugin_mapping('<Plug>FlogUpdate', '<Plug>(FlogUpdate)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Flogupdate', '<Plug>(FlogUpdate)', 'nmap')

call flog#deprecate_plugin_mapping('<Plug>FlogGit', '<Plug>(FlogGit)')
call flog#deprecate_plugin_mapping('<Plug>Floggit', '<Plug>(FlogGit)')

call flog#deprecate_plugin_mapping('<Plug>FlogYank', '<Plug>(FlogYank)')
call flog#deprecate_plugin_mapping('<Plug>Flogyank', '<Plug>(FlogYank)')

call flog#deprecate_plugin_mapping('<Plug>FlogSearch', '<Plug>(FlogSearch)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogPatchSearch', '<Plug>(FlogPatchSearch)', 'nmap')

call flog#deprecate_plugin_mapping('<Plug>FlogQuit', '<Plug>(FlogQuit)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Flogquit', '<Plug>(FlogQuit)', 'nmap')

call flog#deprecate_plugin_mapping('<Plug>FlogHelp', '<Plug>(FlogHelp)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>Floghelp', '<Plug>(FlogHelp)', 'nmap')

call flog#deprecate_plugin_mapping('<Plug>FlogSetskip', '<Plug>(FlogSetSkip)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogSkipahead', '<Plug>(FlogSkipAhead)', 'nmap')
call flog#deprecate_plugin_mapping('<Plug>FlogSkipback', '<Plug>(FlogSkipBack)', 'nmap')

" }}}

" }}}

" Commands {{{

command! -buffer Flogsplitcommit call flog#run_tmp_command('<mods> Gsplit %h')

command! -buffer -bang -complete=customlist,flog#complete -nargs=* Flogsetargs call flog#update_options([<f-args>], '<bang>' ==# '!')

command! -buffer -bang -complete=customlist,flog#complete_jump -nargs=* Flogjump call flog#jump_to_ref(<q-args>)

command! -buffer Flogmarks call flog#echo_commit_marks()

" Deprecated commands {{{

command! -buffer -nargs=* Flogupdate call flog#deprecate_command('Flogupdate', 'Flogsetargs')

" }}}

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
