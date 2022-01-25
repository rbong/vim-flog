" Settings

silent setlocal
      \ bufhidden=wipe
      \ buftype=nofile
      \ cursorline
      \ nobuflisted
      \ nomodeline
      \ nomodifiable
      \ noswapfile
      \ nowrap
      \ readonly

" Commands

command! -buffer -bang -range=0 -complete=customlist,flog#cmd#flog#args#complete -nargs=* Flogsetargs call flog#cmd#flog_set_args([<f-args>], !empty('<bang>'))
command! -buffer Flogsplitcommit call flog#exec('<mods> Gsplit %h', 0, 0, 1)
command! -buffer Flogmarks call flog#floggraph#mark#print_all()

" Deprecated commands

command! -buffer -bang -nargs=* Flogjump call flog#deprecate#command('Flogjump', '/ or ?')

" Misc. Mappings

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
nnoremap <buffer> <silent> <Plug>(FlogVSplitCommitPathsRight) :<C-U>call flog#exec_tmp('vertical belowright Git show %h -- %p', 0, 0)<CR>

if !hasmapto('<Plug>(FlogGit)')
  nmap <buffer> git <Plug>(FlogGit)
  vmap <buffer> git <Plug>(FlogGit)
endif
nnoremap <buffer> <Plug>(FlogGit) :Floggit
vnoremap <buffer> <Plug>(FlogGit) :Floggit

if !hasmapto('<Plug>(FlogYank)')
  nmap <buffer> y<C-G> <Plug>(FlogYank)
  vmap <buffer> y<C-G> <Plug>(FlogYank)
endif
nnoremap <buffer> <silent> <Plug>(FlogYank) :<C-U>call flog#floggraph#reg#yank_hash(v:register, '.', max([1, v:count]))<CR>
vnoremap <buffer> <silent> <Plug>(FlogYank) :<C-U>call flog#floggraph#reg#yank_hash_range(v:register, "'<", "'>")<CR>

if !hasmapto('<Plug>(FlogUpdate)')
  nmap <buffer> u <Plug>(FlogUpdate)
endif
nnoremap <buffer> <silent> <Plug>(FlogUpdate) :<C-U>call flog#floggraph#buf#update()<CR>

if !hasmapto('<Plug>(FlogCloseTmpWin)')
  nmap <buffer> dq <Plug>(FlogCloseTmpWin)
endif

nnoremap <buffer> <silent> <Plug>(FlogCloseTmpWin) :<C-U>call flog#floggraph#side_win#close_tmp()<CR>

if !hasmapto('<Plug>(FlogQuit)')
  nmap <buffer> ZZ <Plug>(FlogQuit)
  nmap <buffer> gq <Plug>(FlogQuit)
endif
nnoremap <buffer> <silent> <Plug>(FlogQuit) :<C-U>call flog#floggraph#buf#close()<CR>

" Diff mappings

if !hasmapto('<Plug>(FlogVDiffSplitRight)')
  nmap <buffer> dd <Plug>(FlogVDiffSplitRight)
  vmap <buffer> dd <Plug>(FlogVDiffSplitRight)
  nmap <buffer> dv <Plug>(FlogVDiffSplitRight)
  vmap <buffer> dv <Plug>(FlogVDiffSplitRight)
endif

if !hasmapto('<Plug>(FlogVDiffSplitPathsRight)')
  nmap <buffer> DD <Plug>(FlogVDiffSplitPathsRight)
  vmap <buffer> DD <Plug>(FlogVDiffSplitPathsRight)
  nmap <buffer> DV <Plug>(FlogVDiffSplitPathsRight)
  vmap <buffer> DV <Plug>(FlogVDiffSplitPathsRight)
endif

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitRight) :<C-U>call flog#exec_tmp('vertical belowright Git diff HEAD %h', 0, 0)<CR>
vnoremap <buffer> <silent> <Plug>(FlogVDiffSplitRight) :<C-U>call flog#exec_tmp("vertical belowright Git diff %(h'>) %(h'<)", 0, 0)<CR>

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitPathsRight) :<C-U>call flog#exec_tmp('vertical belowright Git diff HEAD %h -- %p', 0, 0)<CR>
vnoremap <buffer> <silent> <Plug>(FlogVDiffSplitPathsRight) :<C-U>call flog#exec_tmp("vertical belowright Git diff HEAD %(h'<) %(h'>) -- %p", 0, 0)<CR>

if !hasmapto('<Plug>(FlogVDiffSplitLastCommitRight)')
  nmap <buffer> d! <Plug>(FlogVDiffSplitLastCommitRight)
endif

if !hasmapto('<Plug>(FlogVDiffSplitLastCommitPathsRight)')
  nmap <buffer> D! <Plug>(FlogVDiffSplitLastCommitPathsRight)
endif

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitLastCommitRight) :<C-U> call flog#exec_tmp("vertical belowright Git diff %(h'!) %H", 0, 0)<CR>

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitLastCommitPathsRight) :<C-U> call flog#exec_tmp("vertical belowright Git diff %(h'!) %H -- %p", 0, 0)<CR>

" Navigation mappings

if !hasmapto('<Plug>(FlogJumpToCommitCol)')
  nmap <buffer> ^ <Plug>(FlogJumpToCommitCol)
  vmap <buffer> ^ <Plug>(FlogJumpToCommitCol)
endif
nnoremap <buffer> <silent> <Plug>(FlogJumpToCommitCol) :<C-U>call flog#floggraph#nav#jump_to_commit_col()<CR>
vnoremap <buffer> <silent> <Plug>(FlogJumpToCommitCol) :<C-U>call flog#floggraph#nav#jump_to_commit_col()<CR>

if !hasmapto('<Plug>(FlogNextCommit)')
  nmap <buffer> ) <Plug>(FlogNextCommit)
endif
if !hasmapto('<Plug>(FlogPrevCommit)')
  nmap <buffer> ( <Plug>(FlogPrevCommit)
endif
nnoremap <buffer> <silent> <Plug>(FlogNextCommit) :<C-U>call flog#floggraph#nav#next_commit(max([1, v:count]))<CR>
nnoremap <buffer> <silent> <Plug>(FlogPrevCommit) :<C-U>call flog#floggraph#nav#prev_commit(max([1, v:count]))<CR>

if !hasmapto('<Plug>(FlogVNextCommitRight)')
  nmap <buffer> <C-N> <Plug>(FlogVNextCommitRight)
endif
if !hasmapto('<Plug>(FlogVPrevCommitRight)')
  nmap <buffer> <C-P> <Plug>(FlogVPrevCommitRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVNextCommitRight) :<C-U>call flog#floggraph#nav#next_commit(max([1, v:count])) \| vertical belowright Flogsplitcommit<CR>
nnoremap <buffer> <silent> <Plug>(FlogVPrevCommitRight) :<C-U>call flog#floggraph#nav#prev_commit(max([1, v:count])) \| vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>(FlogVNextRefRight)')
  nmap <buffer> ]r <Plug>(FlogVNextRefRight)
endif
if !hasmapto('<Plug>(FlogVPrevRefRight)')
  nmap <buffer> [r <Plug>(FlogVPrevRefRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVNextRefRight) :<C-U>call flog#floggraph#nav#next_ref_commit(max([1, v:count]))<CR>
nnoremap <buffer> <silent> <Plug>(FlogVPrevRefRight) :<C-U>call flog#floggraph#nav#prev_ref_commit(max([1, v:count]))<CR>

if !hasmapto('<Plug>(FlogSkipAhead)')
  nmap <buffer> ]] <Plug>(FlogSkipAhead)
endif
nnoremap <buffer> <silent> <Plug>(FlogSkipAhead) :<C-U>call flog#floggraph#nav#skip_ahead(max([v:count, 1]))<CR>

if !hasmapto('<Plug>(FlogSkipBack)')
  nmap <buffer> [[ <Plug>(FlogSkipBack)
endif
nnoremap <buffer> <silent> <Plug>(FlogSkipBack) :<C-U>call flog#floggraph#nav#skip_back(max([v:count, 1]))<CR>

if !hasmapto('<Plug>(FlogSetSkip)')
  nmap <buffer> go <Plug>(FlogSetSkip)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetSkip) :<C-U>call flog#floggraph#nav#skip_to(v:count)<CR>

if !hasmapto('<Plug>(FlogSetRev)')
  nmap <buffer> gct <Plug>(FlogSetRev)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetRev) :<C-U>call flog#exec("call flog#floggraph#nav#set_rev('%h')", 0, 0, 0)<CR>

if !hasmapto('<Plug>(FlogClearRev)')
  nmap <buffer> gcc <Plug>(FlogClearRev)
endif
nnoremap <buffer> <silent> <Plug>(FlogClearRev) :<C-U>call flog#floggraph#nav#set_rev('')<CR>

" Argument modifier mappings

if !hasmapto('<Plug>(FlogToggleAll)')
  nmap <buffer> a <Plug>(FlogToggleAll)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleAll) :<C-U>call flog#floggraph#opts#toggle_all()<CR>

if !hasmapto('<Plug>(FlogToggleBisect)')
  nmap <buffer> gb <Plug>(FlogToggleBisect)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleBisect) :<C-U>call flog#floggraph#opts#toggle_bisect()<CR>

if !hasmapto('<Plug>(FlogToggleMerges)')
  nmap <buffer> gm <Plug>(FlogToggleMerges)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleMerges) :<C-U>call flog#floggraph#opts#toggle_merges()<CR>

if !hasmapto('<Plug>(FlogToggleReflog)')
  nmap <buffer> gr <Plug>(FlogToggleReflog)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleReflog) :<C-U>call flog#floggraph#opts#toggle_reflog()<CR>

if !hasmapto('<Plug>(FlogToggleGraph)')
  nmap <buffer> gx <Plug>(FlogToggleGraph)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleGraph) :<C-U>call flog#floggraph#opts#toggle_graph()<CR>

if !hasmapto('<Plug>(FlogTogglePatch)')
  nmap <buffer> gp <Plug>(FlogTogglePatch)
endif
nnoremap <buffer> <silent> <Plug>(FlogTogglePatch) :<C-U>call flog#floggraph#opts#toggle_patch()<CR>

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
nnoremap <buffer> <silent> <Plug>(FlogCycleSort) :<C-U>call flog#floggraph#opts#cycle_sort()<CR>

if !hasmapto('<Plug>(FlogSortDate)')
  nmap <buffer> gsd <Plug>(FlogSortDate)
endif
nnoremap <buffer> <silent> <Plug>(FlogSortDate) :<C-U>Flogsetargs -sort=date<CR>

if !hasmapto('<Plug>(FlogSortAuthor)')
  nmap <buffer> gsa <Plug>(FlogSortAuthor)
endif
nnoremap <buffer> <silent> <Plug>(FlogSortAuthor) :<C-U>Flogsetargs -sort=author<CR>

if !hasmapto('<Plug>(FlogSortTopo)')
  nmap <buffer> gst <Plug>(FlogSortTopo)
endif
nnoremap <buffer> <silent> <Plug>(FlogSortTopo) :<C-U>Flogsetargs -sort=topo<CR>

if !hasmapto('<Plug>(FlogToggleReverse)')
  nmap <buffer> gsr <Plug>(FlogToggleReverse)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleReverse) :<C-U>call flog#floggraph#opts#toggle_reverse()<CR>

" Commit/branch mappings

if !hasmapto('<Plug>(FlogFixup)')
  nmap <buffer> cf <Plug>(FlogFixup)
endif
if !hasmapto('<Plug>(FlogFixupRebase)')
  nmap <buffer> cF <Plug>(FlogFixupRebase)
endif
nnoremap <buffer> <silent> <Plug>(FlogFixup) :<C-U>call flog#exec('Git commit --fixup=%H', 1, 1, 0)<CR>
nnoremap <buffer> <silent> <Plug>(FlogFixupRebase) :<C-U>call flog#exec('Git commit --fixup=%H \| Git -c sequence.editor=true rebase --interactive --autosquash %H^', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogSquash)')
  nmap <buffer> cs <Plug>(FlogSquash)
endif
if !hasmapto('<Plug>(FlogSquashRebase)')
  nmap <buffer> cS <Plug>(FlogSquashRebase)
endif
if !hasmapto('<Plug>(FlogSquashEdit)')
  nmap <buffer> cA <Plug>(FlogSquashEdit)
endif
nnoremap <buffer> <silent> <Plug>(FlogSquash) :<C-U>call flog#exec('Git commit --no-edit --squash=%H', 1, 1, 0)<CR>
nnoremap <buffer> <silent> <Plug>(FlogSquashRebase) :<C-U>call flog#exec('Git commit --no-edit --squash=%H \| Git -c sequence.editor=true rebase --interactive --autosquash %H^', 1, 1, 0)<CR>
nnoremap <buffer> <silent> <Plug>(FlogSquashEdit) :<C-U>call flog#exec('Git commit --edit --squash=%H', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRevert)')
  nmap <buffer> crc <Plug>(FlogRevert)
  vmap <buffer> crc <Plug>(FlogRevert)
endif

if !hasmapto('<Plug>(FlogRevertNoEdit)')
  nmap <buffer> crn <Plug>(FlogRevertNoEdit)
  vmap <buffer> crn <Plug>(FlogRevertNoEdit)
endif

nnoremap <buffer> <silent> <Plug>(FlogRevert) :<C-U>call flog#exec('Git revert %H', 1, 1, 0)<CR>
vnoremap <buffer> <silent> <Plug>(FlogRevert) :<C-U>call flog#exec("Git revert %(h'<)^..%(h'>)", 1, 1, 0)<CR>

nnoremap <buffer> <silent> <Plug>(FlogRevertNoEdit) :<C-U>call flog#exec('Git revert --no-edit %H', 1, 1, 0)<CR>
vnoremap <buffer> <silent> <Plug>(FlogRevertNoEdit) :<C-U>call flog#exec("Git revert --no-edit %(h'<)^..%(h'>)", 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogCheckout)')
  nmap <buffer> coo <Plug>(FlogCheckout)
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckout) :<C-U>call flog#exec('Git checkout %H', 0, 1, 0)<CR>

if !hasmapto('<Plug>(FlogCheckoutBranch)')
  nmap <buffer> cob <Plug>(FlogCheckoutBranch)
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckoutBranch) :<C-U>call flog#exec('Git checkout %b', 0, 1, 0)<CR>

if !hasmapto('<Plug>(FlogCheckoutLocalBranch)')
  nmap <buffer> col <Plug>(FlogCheckoutLocalBranch)

  if !hasmapto('cot')
    nnoremap <buffer> <silent> cot :<C-U>call flog#deprecate#default_mapping('cot', 'col')<CR>
  endif
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckoutLocalBranch) :<C-U>call flog#exec('Git checkout %l', 0, 1, 0)<CR>

if !hasmapto('<Plug>(FlogGitCommit)')
  nmap <buffer> c<Space> <Plug>(FlogGitCommit)
  vmap <buffer> c<Space> <Plug>(FlogGitCommit)
endif
nnoremap <buffer> <Plug>(FlogGitCommit) :Floggit commit<Space>
vnoremap <buffer> <Plug>(FlogGitCommit) :Floggit commit<Space>

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

" Mark mappings

if !hasmapto('<Plug>(FlogSetCommitMark)')
  nmap <buffer> m <Plug>(FlogSetCommitMark)
  vmap <buffer> m <Plug>(FlogSetCommitMark)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetCommitMark) :<C-U>call flog#floggraph#mark#set(nr2char(getchar()), '.')<CR>
vnoremap <buffer> <silent> <Plug>(FlogSetCommitMark) :<C-U>call flog#floggraph#mark#set(nr2char(getchar()), '.')<CR>

if !hasmapto('<Plug>(FlogJumpToCommitMark)')
  nmap <buffer> ' <Plug>(FlogJumpToCommitMark)
  vmap <buffer> ' <Plug>(FlogJumpToCommitMark)
endif
nnoremap <buffer> <silent> <Plug>(FlogJumpToCommitMark) :<C-U>call flog#floggraph#nav#jump_to_mark(nr2char(getchar()))<CR>
vnoremap <buffer> <silent> <Plug>(FlogJumpToCommitMark) :<C-U>call flog#floggraph#nav#jump_to_mark(nr2char(getchar()))<CR>

" Rebase mappings

if !hasmapto('<Plug>(FlogRebaseInteractive)')
  nmap <buffer> ri <Plug>(FlogRebaseInteractive)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractive) :<C-U>call flog#exec('Git rebase --interactive %H^', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveAutosquash)')
  nmap <buffer> rf <Plug>(FlogRebaseInteractiveAutosquash)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveAutosquash) :<C-U>call flog#exec('Git -c sequence.editor=true rebase --interactive --autosquash %H^', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveUpstream)')
  nmap <buffer> ru <Plug>(FlogRebaseInteractiveUpstream)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveUpstream) :<C-U>call flog#exec('Git rebase --interactive @{upstream}', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractivePush)')
  nmap <buffer> rp <Plug>(FlogRebaseInteractivePush)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractivePush) :<C-U>call flog#exec('Git rebase --interactive @{push}', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseContinue)')
  nmap <buffer> rr <Plug>(FlogRebaseContinue)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseContinue) :<C-U>call flog#exec('Git rebase --continue', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseSkip)')
  nmap <buffer> rs <Plug>(FlogRebaseSkip)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseSkip) :<C-U>call flog#exec('Git rebase --skip', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseAbort)')
  nmap <buffer> ra <Plug>(FlogRebaseAbort)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseAbort) :<C-U>call flog#exec('Git rebase --abort', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseEditTodo)')
  nmap <buffer> re <Plug>(FlogRebaseEditTodo)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseEditTodo) :<C-U>call flog#exec('Git rebase --edit-todo', 1, 1, 0)<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveReword)')
  nmap <buffer> rw <Plug>(FlogRebaseInteractiveReword)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveReword) :<C-U>call flog#exec('Git rebase --interactive %H^ \| s/^pick/reword/e', 1, 1, 0)

if !hasmapto('<Plug>(FlogRebaseInteractiveEdit)')
  nmap <buffer> rm <Plug>(FlogRebaseInteractiveEdit)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveEdit) :<C-U>call flog#exec('Git rebase --interactive %H^ \| s/^pick/edit/e', 1, 1, 0)

if !hasmapto('<Plug>(FlogRebaseInteractiveDrop)')
  nmap <buffer> rd <Plug>(FlogRebaseInteractiveDrop)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveDrop) :<C-U>call flog#exec('Git rebase --interactive %H^ \| s/^pick/drop/e', 1, 1, 0)

if !hasmapto('<Plug>(FlogGitRebase)')
  nmap <buffer> r<Space> <Plug>(FlogGitRebase)
  vmap <buffer> r<Space> <Plug>(FlogGitRebase)
endif
nnoremap <buffer> <Plug>(FlogGitRebase) :Floggit rebase<Space>
vnoremap <buffer> <Plug>(FlogGitRebase) :Floggit rebase<Space>
