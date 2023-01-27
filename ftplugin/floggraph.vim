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

command! -buffer -bang -range=0 -complete=customlist,flog#cmd#flog#args#Complete -nargs=* Flogsetargs call flog#cmd#FlogSetArgs([<f-args>], !empty('<bang>'))
command! -buffer Flogsplitcommit call flog#Exec(flog#Format('<mods> Gsplit %h'), 0, 1, 1)
command! -buffer Flogmarks call flog#floggraph#mark#PrintAll()

" Deprecated commands

command! -buffer -bang -nargs=* Flogjump call flog#deprecate#Command('Flogjump', '/ or ?')

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
nnoremap <buffer> <silent> <Plug>(FlogVSplitCommitPathsRight) :<C-U>exec flog#Format('vertical belowright Floggit -s -t show %h -- %p')<CR>

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
nnoremap <buffer> <silent> <Plug>(FlogYank) :<C-U>call flog#floggraph#reg#YankHash(v:register, '.', max([1, v:count]))<CR>
vnoremap <buffer> <silent> <Plug>(FlogYank) :<C-U>call flog#floggraph#reg#YankHashRange(v:register, "'<", "'>")<CR>

if !hasmapto('<Plug>(FlogUpdate)')
  nmap <buffer> u <Plug>(FlogUpdate)
endif
nnoremap <buffer> <silent> <Plug>(FlogUpdate) :<C-U>call flog#floggraph#buf#Update()<CR>

if !hasmapto('<Plug>(FlogVSplitStaged)')
  nmap <buffer> gs <Plug>(FlogVSplitStaged)
endif
if !hasmapto('<Plug>(FlogVSplitUntracked)')
  nmap <buffer> gu <Plug>(FlogVSplitUntracked)
endif
if !hasmapto('<Plug>(FlogVSplitUnstaged)')
  nmap <buffer> gU <Plug>(FlogVSplitUnstaged)
endif

nnoremap <buffer> <silent> <Plug>(FlogVSplitStaged) :<C-U>vertical belowright Floggit -s -t diff --cached<CR>
nnoremap <buffer> <silent> <Plug>(FlogVSplitUntracked) :<C-U>exec flog#Format('silent Git add -N . \| vertical belowright Floggit -s -t diff \| silent Git read-tree %t')<CR>
nnoremap <buffer> <silent> <Plug>(FlogVSplitUnstaged) :<C-U>vertical belowright Floggit -s -t diff<CR>

if !hasmapto('<Plug>(FlogCloseTmpWin)')
  nmap <buffer> dq <Plug>(FlogCloseTmpWin)
endif

nnoremap <buffer> <silent> <Plug>(FlogCloseTmpWin) :<C-U>call flog#floggraph#side_win#CloseTmp()<CR>

if !hasmapto('<Plug>(FlogQuit)')
  nmap <buffer> ZZ <Plug>(FlogQuit)
  nmap <buffer> gq <Plug>(FlogQuit)
endif
nnoremap <buffer> <silent> <Plug>(FlogQuit) :<C-U>call flog#floggraph#buf#Close()<CR>

" Navigation mappings

if !hasmapto('<Plug>(FlogJumpToCommitStart)')
  nmap <buffer> ^ <Plug>(FlogJumpToCommitStart)
  vmap <buffer> ^ <Plug>(FlogJumpToCommitStart)
endif
nnoremap <buffer> <silent> <Plug>(FlogJumpToCommitStart) :<C-U>call flog#floggraph#nav#JumpToCommitStart()<CR>
vnoremap <buffer> <silent> <Plug>(FlogJumpToCommitStart) :<C-U>call flog#floggraph#nav#JumpToCommitStart()<CR>

if !hasmapto('<Plug>(FlogNextCommit)')
  nmap <buffer> ) <Plug>(FlogNextCommit)
endif
if !hasmapto('<Plug>(FlogPrevCommit)')
  nmap <buffer> ( <Plug>(FlogPrevCommit)
endif
nnoremap <buffer> <silent> <Plug>(FlogNextCommit) :<C-U>call flog#floggraph#nav#NextCommit(max([1, v:count]))<CR>
nnoremap <buffer> <silent> <Plug>(FlogPrevCommit) :<C-U>call flog#floggraph#nav#PrevCommit(max([1, v:count]))<CR>

if !hasmapto('<Plug>(FlogVNextCommitRight)')
  nmap <buffer> <C-N> <Plug>(FlogVNextCommitRight)
endif
if !hasmapto('<Plug>(FlogVPrevCommitRight)')
  nmap <buffer> <C-P> <Plug>(FlogVPrevCommitRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVNextCommitRight) :<C-U>call flog#floggraph#nav#NextCommit(max([1, v:count])) \| vertical belowright Flogsplitcommit<CR>
nnoremap <buffer> <silent> <Plug>(FlogVPrevCommitRight) :<C-U>call flog#floggraph#nav#PrevCommit(max([1, v:count])) \| vertical belowright Flogsplitcommit<CR>

if !hasmapto('<Plug>(FlogVNextRefRight)')
  nmap <buffer> ]r <Plug>(FlogVNextRefRight)
endif
if !hasmapto('<Plug>(FlogVPrevRefRight)')
  nmap <buffer> [r <Plug>(FlogVPrevRefRight)
endif
nnoremap <buffer> <silent> <Plug>(FlogVNextRefRight) :<C-U>call flog#floggraph#nav#NextRefCommit(max([1, v:count]))<CR>
nnoremap <buffer> <silent> <Plug>(FlogVPrevRefRight) :<C-U>call flog#floggraph#nav#PrevRefCommit(max([1, v:count]))<CR>

if !hasmapto('<Plug>(FlogSkipAhead)')
  nmap <buffer> ]] <Plug>(FlogSkipAhead)
endif
nnoremap <buffer> <silent> <Plug>(FlogSkipAhead) :<C-U>call flog#floggraph#nav#SkipAhead(max([v:count, 1]))<CR>

if !hasmapto('<Plug>(FlogSkipBack)')
  nmap <buffer> [[ <Plug>(FlogSkipBack)
endif
nnoremap <buffer> <silent> <Plug>(FlogSkipBack) :<C-U>call flog#floggraph#nav#SkipBack(max([v:count, 1]))<CR>

if !hasmapto('<Plug>(FlogSetSkip)')
  nmap <buffer> gcg <Plug>(FlogSetSkip)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetSkip) :<C-U>call flog#floggraph#nav#SkipTo(v:count)<CR>

if !hasmapto('<Plug>(FlogSetRev)')
  nmap <buffer> gct <Plug>(FlogSetRev)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetRev) :<C-U>call flog#floggraph#nav#SetRevToCommitAtLine('.')<CR>

if !hasmapto('<Plug>(FlogClearRev)')
  nmap <buffer> gcc <Plug>(FlogClearRev)
endif
nnoremap <buffer> <silent> <Plug>(FlogClearRev) :<C-U>call flog#floggraph#nav#ClearRev()<CR>

" Mark mappings

if !hasmapto('<Plug>(FlogSetCommitMark)')
  nmap <buffer> m <Plug>(FlogSetCommitMark)
  vmap <buffer> m <Plug>(FlogSetCommitMark)
endif
nnoremap <buffer> <silent> <Plug>(FlogSetCommitMark) :<C-U>call flog#floggraph#mark#Set(nr2char(getchar()), '.')<CR>
vnoremap <buffer> <silent> <Plug>(FlogSetCommitMark) :<C-U>call flog#floggraph#mark#Set(nr2char(getchar()), '.')<CR>

if !hasmapto('<Plug>(FlogJumpToCommitMark)')
  nmap <buffer> ' <Plug>(FlogJumpToCommitMark)
  vmap <buffer> ' <Plug>(FlogJumpToCommitMark)
endif
nnoremap <buffer> <silent> <Plug>(FlogJumpToCommitMark) :<C-U>call flog#floggraph#nav#JumpToMark(nr2char(getchar()))<CR>
vnoremap <buffer> <silent> <Plug>(FlogJumpToCommitMark) :<C-U>call flog#floggraph#nav#JumpToMark(nr2char(getchar()))<CR>

" Argument modifier mappings

if !hasmapto('<Plug>(FlogToggleAll)')
  nmap <buffer> a <Plug>(FlogToggleAll)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleAll) :<C-U>call flog#floggraph#opts#ToggleAll()<CR>

if !hasmapto('<Plug>(FlogToggleBisect)')
  nmap <buffer> gb <Plug>(FlogToggleBisect)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleBisect) :<C-U>call flog#floggraph#opts#ToggleBisect()<CR>

if !hasmapto('<Plug>(FlogToggleMerges)')
  nmap <buffer> gm <Plug>(FlogToggleMerges)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleMerges) :<C-U>call flog#floggraph#opts#ToggleMerges()<CR>

if !hasmapto('<Plug>(FlogToggleReflog)')
  nmap <buffer> gr <Plug>(FlogToggleReflog)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleReflog) :<C-U>call flog#floggraph#opts#ToggleReflog()<CR>

if !hasmapto('<Plug>(FlogToggleGraph)')
  nmap <buffer> gx <Plug>(FlogToggleGraph)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleGraph) :<C-U>call flog#floggraph#opts#ToggleGraph()<CR>

if !hasmapto('<Plug>(FlogTogglePatch)')
  nmap <buffer> gp <Plug>(FlogTogglePatch)
endif
nnoremap <buffer> <silent> <Plug>(FlogTogglePatch) :<C-U>call flog#floggraph#opts#TogglePatch()<CR>

if !hasmapto('<Plug>(FlogSearch)')
  nmap <buffer> g/ <Plug>(FlogSearch)
endif
nnoremap <buffer> <Plug>(FlogSearch) :<C-U>Flogsetargs -search=

if !hasmapto('<Plug>(FlogPatchSearch)')
  nmap <buffer> g\ <Plug>(FlogPatchSearch)
endif
nnoremap <buffer> <Plug>(FlogPatchSearch) :<C-U>Flogsetargs -patch-search=

if !hasmapto('<Plug>(FlogCycleOrder)')
  nmap <buffer> goo <Plug>(FlogCycleOrder)
endif
nnoremap <buffer> <silent> <Plug>(FlogCycleOrder) :<C-U>call flog#floggraph#opts#CycleOrder()<CR>

if !hasmapto('<Plug>(FlogOrderDate)')
  nmap <buffer> god <Plug>(FlogOrderDate)
endif
nnoremap <buffer> <silent> <Plug>(FlogOrderDate) :<C-U>Flogsetargs -order=date<CR>

if !hasmapto('<Plug>(FlogOrderAuthor)')
  nmap <buffer> goa <Plug>(FlogOrderAuthor)
endif
nnoremap <buffer> <silent> <Plug>(FlogOrderAuthor) :<C-U>Flogsetargs -order=author<CR>

if !hasmapto('<Plug>(FlogOrderTopo)')
  nmap <buffer> got <Plug>(FlogOrderTopo)
endif
nnoremap <buffer> <silent> <Plug>(FlogOrderTopo) :<C-U>Flogsetargs -order=topo<CR>

if !hasmapto('<Plug>(FlogToggleReverse)')
  nmap <buffer> gor <Plug>(FlogToggleReverse)
endif
nnoremap <buffer> <silent> <Plug>(FlogToggleReverse) :<C-U>call flog#floggraph#opts#ToggleReverse()<CR>

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

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitRight) :<C-U>exec flog#Format('vertical belowright Floggit -s -t diff HEAD %h')<CR>
vnoremap <buffer> <silent> <Plug>(FlogVDiffSplitRight) :<C-U>exec flog#Format("vertical belowright Floggit -s -t diff %(h'>) %(h'<)")<CR>

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitPathsRight) :<C-U>exec flog#Format('vertical belowright Floggit -s -t diff HEAD %h -- %p')<CR>
vnoremap <buffer> <silent> <Plug>(FlogVDiffSplitPathsRight) :<C-U>exec flog#Format("vertical belowright Floggit -s -t diff HEAD %(h'<) %(h'>) -- %p")<CR>

if !hasmapto('<Plug>(FlogVDiffSplitLastCommitRight)')
  nmap <buffer> d! <Plug>(FlogVDiffSplitLastCommitRight)
endif

if !hasmapto('<Plug>(FlogVDiffSplitLastCommitPathsRight)')
  nmap <buffer> D! <Plug>(FlogVDiffSplitLastCommitPathsRight)
endif

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitLastCommitRight) :<C-U>exec flog#Format("vertical belowright Floggit -s -t diff %(h'!) %H")<CR>

nnoremap <buffer> <silent> <Plug>(FlogVDiffSplitLastCommitPathsRight) :<C-U>exec flog#Format("vertical belowright Floggit -s -t diff %(h'!) %H -- %p")<CR>

if !hasmapto('<Plug>(FlogDiffHelp)')
  nmap <buffer> d? <Plug>(FlogDiffHelp)
endif
nnoremap <buffer> <silent> <Plug>(FlogDiffHelp) :help flog-diff-mappings<CR>

" Commit/branch mappings

if !hasmapto('<Plug>(FlogFixup)')
  nmap <buffer> cf <Plug>(FlogFixup)
endif
if !hasmapto('<Plug>(FlogFixupRebase)')
  nmap <buffer> cF <Plug>(FlogFixupRebase)
endif
nnoremap <buffer> <silent> <Plug>(FlogFixup) :<C-U>exec flog#Format('Floggit -f commit --fixup=%H')<CR>
nnoremap <buffer> <silent> <Plug>(FlogFixupRebase) :<C-U>exec flog#Format('Git commit --fixup=%H \| Floggit -f -c sequence.editor=true rebase --interactive --autosquash %H^')<CR>

if !hasmapto('<Plug>(FlogSquash)')
  nmap <buffer> cs <Plug>(FlogSquash)
endif
if !hasmapto('<Plug>(FlogSquashRebase)')
  nmap <buffer> cS <Plug>(FlogSquashRebase)
endif
if !hasmapto('<Plug>(FlogSquashEdit)')
  nmap <buffer> cA <Plug>(FlogSquashEdit)
endif
nnoremap <buffer> <silent> <Plug>(FlogSquash) :<C-U>exec flog#Format('Floggit -f commit --no-edit --squash=%H')<CR>
nnoremap <buffer> <silent> <Plug>(FlogSquashRebase) :<C-U>exec flog#Format('Git commit --no-edit --squash=%H \| Floggit -f -c sequence.editor=true rebase --interactive --autosquash %H^')<CR>
nnoremap <buffer> <silent> <Plug>(FlogSquashEdit) :<C-U>exec flog#Format('Floggit -f commit --edit --squash=%H')<CR>

if !hasmapto('<Plug>(FlogRevert)')
  nmap <buffer> crc <Plug>(FlogRevert)
  vmap <buffer> crc <Plug>(FlogRevert)
endif

if !hasmapto('<Plug>(FlogRevertNoEdit)')
  nmap <buffer> crn <Plug>(FlogRevertNoEdit)
  vmap <buffer> crn <Plug>(FlogRevertNoEdit)
endif

nnoremap <buffer> <silent> <Plug>(FlogRevert) :<C-U>exec flog#Format('Floggit -f revert %H')<CR>
vnoremap <buffer> <silent> <Plug>(FlogRevert) :<C-U>exec flog#Format("Floggit -f revert %(h'<)^..%(h'>)")<CR>

nnoremap <buffer> <silent> <Plug>(FlogRevertNoEdit) :<C-U>exec flog#Format('Floggit -f revert --no-edit %H')<CR>
vnoremap <buffer> <silent> <Plug>(FlogRevertNoEdit) :<C-U>exec flog#Format("Floggit -f revert --no-edit %(h'<)^..%(h'>)")<CR>

if !hasmapto('<Plug>(FlogCheckout)')
  nmap <buffer> coo <Plug>(FlogCheckout)
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckout) :<C-U>exec flog#Format('Floggit checkout %H')<CR>

if !hasmapto('<Plug>(FlogCheckoutBranch)')
  nmap <buffer> cob <Plug>(FlogCheckoutBranch)
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckoutBranch) :<C-U>exec flog#Format('Floggit checkout %b')<CR>

if !hasmapto('<Plug>(FlogCheckoutLocalBranch)')
  nmap <buffer> col <Plug>(FlogCheckoutLocalBranch)

  if !hasmapto('cot')
    nnoremap <buffer> <silent> cot :<C-U>call flog#deprecate#DefaultMapping('cot', 'col')<CR>
  endif
endif
nnoremap <buffer> <silent> <Plug>(FlogCheckoutLocalBranch) :<C-U>exec flog#Format('Floggit checkout %l')<CR>

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

if !hasmapto('<Plug>(FlogCommitHelp)')
  nmap <buffer> c? <Plug>(FlogCommitHelp)
endif
nnoremap <buffer> <silent> <Plug>(FlogCommitHelp) :help flog-commit-mappings<CR>

" Rebase mappings

if !hasmapto('<Plug>(FlogRebaseInteractive)')
  nmap <buffer> ri <Plug>(FlogRebaseInteractive)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractive) :<C-U>exec flog#Format('Floggit -f rebase --interactive %H')<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveAutosquash)')
  nmap <buffer> rf <Plug>(FlogRebaseInteractiveAutosquash)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveAutosquash) :<C-U>exec flog#Format('Floggit -f -c sequence.editor=true rebase --interactive --autosquash %H')<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveUpstream)')
  nmap <buffer> ru <Plug>(FlogRebaseInteractiveUpstream)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveUpstream) :<C-U>Floggit -f rebase --interactive @{upstream}<CR>

if !hasmapto('<Plug>(FlogRebaseInteractivePush)')
  nmap <buffer> rp <Plug>(FlogRebaseInteractivePush)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractivePush) :<C-U>Floggit -f rebase --interactive @{push}<CR>

if !hasmapto('<Plug>(FlogRebaseContinue)')
  nmap <buffer> rr <Plug>(FlogRebaseContinue)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseContinue) :<C-U>Floggit -f rebase --continue<CR>

if !hasmapto('<Plug>(FlogRebaseSkip)')
  nmap <buffer> rs <Plug>(FlogRebaseSkip)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseSkip) :<C-U>Floggit -f rebase --skip<CR>

if !hasmapto('<Plug>(FlogRebaseAbort)')
  nmap <buffer> ra <Plug>(FlogRebaseAbort)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseAbort) :<C-U>Floggit -f rebase --abort<CR>

if !hasmapto('<Plug>(FlogRebaseEditTodo)')
  nmap <buffer> re <Plug>(FlogRebaseEditTodo)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseEditTodo) :<C-U>Floggit -f rebase --edit-todo<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveReword)')
  nmap <buffer> rw <Plug>(FlogRebaseInteractiveReword)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveReword) :<C-U>exec flog#Format('Floggit -f rebase --interactive %H \| s/^pick/reword/e')<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveEdit)')
  nmap <buffer> rm <Plug>(FlogRebaseInteractiveEdit)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveEdit) :<C-U>exec flog#Format('Floggit -f rebase --interactive %H \| s/^pick/edit/e')<CR>

if !hasmapto('<Plug>(FlogRebaseInteractiveDrop)')
  nmap <buffer> rd <Plug>(FlogRebaseInteractiveDrop)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseInteractiveDrop) :<C-U>exec flog#Format('Floggit -f rebase --interactive %H \| s/^pick/drop/e')<CR>

if !hasmapto('<Plug>(FlogGitRebase)')
  nmap <buffer> r<Space> <Plug>(FlogGitRebase)
  vmap <buffer> r<Space> <Plug>(FlogGitRebase)
endif
nnoremap <buffer> <Plug>(FlogGitRebase) :Floggit rebase<Space>
vnoremap <buffer> <Plug>(FlogGitRebase) :Floggit rebase<Space>

if !hasmapto('<Plug>(FlogRebaseHelp)')
  nmap <buffer> r? <Plug>(FlogRebaseHelp)
endif
nnoremap <buffer> <silent> <Plug>(FlogRebaseHelp) :help flog-rebase-mappings<CR>
