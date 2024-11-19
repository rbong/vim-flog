if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'floggraph'

runtime! syntax/diff.vim

" Commit format highlighting

syntax cluster flogCommitInfo contains=flogHash,flogAuthor,flogRef,flogDate

if g:flog_enable_dynamic_commit_hl
  syntax match flogConceal conceal /\e\[./

  syntax region flogHash   start=/\e\[h/ end=/\e\[H\|$/me=e-3 contains=flogConceal
  syntax region flogAuthor start=/\e\[n/ end=/\e\[N\|$/me=e-3 contains=flogConceal
  syntax region flogRef    start=/\e\[r/ end=/\e\[R\|$/me=e-3 contains=flogConceal
  syntax region flogDate   start=/\e\[d/ end=/\e\[D\|$/me=e-3 contains=flogConceal
else
  syntax match flogHash   contained nextgroup=flogAuthor,flogRef,flogDate  /\v%(\].*)@<!\[[0-9a-f]{4,}\]%( |$)/
  syntax match flogAuthor contained nextgroup=flogHash,flogRef,flogDate    /\v%(\}.*)@<!\{.{-}\}%( |$)/
  syntax match flogRef    contained nextgroup=flogHash,flogAuthor,flogDate /\%().*\)\@<!(\%(tag: \| -> \|, \|[^ \\)?*[]\+\)\+)\%( \|$\)/

  " Date patterns
  let weekday_name_pattern = '%(Mon|Monday|Tue|Tuesday|Wed|Wednesday|Thu|Thursday|Fri|Friday|Sat|Saturday|Sun|Sunday)'
  let month_name_pattern = '%(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)'
  let iso_date_pattern = '%(\d{4}-\d\d-\d\d|%())'
  let iso_time_pattern = '%(\d\d:\d\d%(:\d\d%( ?[+-]\d\d:?\d\d)?)?)'

  " ISO format
  exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v' . iso_date_pattern . '%([T ]' . iso_time_pattern . ')?%( |$)/'
  " RFC format
  exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v' . weekday_name_pattern . ', \d{1,2} ' . month_name_pattern . ' \d{4}%( ' . iso_time_pattern . ')?%( |$)/'
  " Local format
  exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v' . weekday_name_pattern . ' ' . month_name_pattern . ' \d{1,2}%( ' . iso_time_pattern . ')? \d{4}' . '%( |$)/'
  " Relative format
  exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v%(\d+ %([yY]ear|[mM]onth|[wW]eek|[dD]ay|[hH]our|[mM]inute|[sS]econd)s?%(, )?)+ [aA]go%( |$)/'
  " Human formats
  exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v' . weekday_name_pattern . ' ' . iso_time_pattern . '%( |$)/'
  exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v' . month_name_pattern . ' \d{1,2} \d{4}' . '%( |$)/'
endif

" Commit ref
syntax match flogRefTag        contained containedin=flogRef /\vtag: \zs.{-}\ze%(, |)\)/
syntax match flogRefRemote     contained containedin=flogRef /\vremotes\/\zs.{-}\ze%(, |)\)/
syntax match flogRefHead       contained containedin=flogRef nextgroup=flogRefHeadArrow  /\<HEAD/
syntax match flogRefHeadArrow  contained                     nextgroup=flogRefHeadBranch / -> /
syntax match flogRefHeadBranch contained                                                 /[^,)]\+/

" Collapsed commit indicator
syntax match flogCollapsedCommit contained /== \d\+ hidden lines ==$/

highlight default link flogHash            Statement
highlight default link flogAuthor          String
highlight default link flogDate            Number
highlight default link flogRef             Directory
highlight default link flogRefTag          String
highlight default link flogRefRemote       Statement
highlight default link flogRefHead         Keyword
highlight default link flogRefHeadArrow    flogRef
highlight default link flogRefHeadBranch   Special
highlight default link flogCollapsedCommit Comment

" Diff highlighting
" Copied from syntax/diff.vim

syntax cluster flogDiff contains=flogDiffAdded,flogDiffBDiffer,flogDiffChanged,flogDiffComment,flogDiffCommon,flogDiffDiffer,flogDiffFile,flogDiffIdentical,flogDiffIndexLine,flogDiffIsA,flogDiffLine,flogDiffNewFile,flogDiffNoEOL,flogDiffOldFile,flogDiffOnly,flogDiffRemoved

syntax match flogDiffOnly      contained /Only in .*/
syntax match flogDiffIdentical contained /Files .* and .* are identical$/
syntax match flogDiffDiffer    contained /Files .* and .* differ$/
syntax match flogDiffBDiffer   contained /Binary files .* and .* differ$/
syntax match flogDiffIsA       contained /File .* is a .* while file .* is a .*/
syntax match flogDiffNoEOL     contained /\\ No newline at end of file .*/
syntax match flogDiffCommon    contained /Common subdirectories: .*/

syntax match flogDiffRemoved contained /-.*/
syntax match flogDiffRemoved contained /<.*/
syntax match flogDiffAdded   contained /+.*/
syntax match flogDiffAdded   contained />.*/
syntax match flogDiffChanged contained /! .*/

syntax match flogDiffSubname contained containedin=flogDiffSubname /@@..*/ms=s+3
syntax match flogDiffLine    contained /@.*/

syntax match flogDiffLine contained /\*\*\*\*.*/
syntax match flogDiffLine contained /---$/
syntax match flogDiffLine contained /\d\+\%(,\d\+\)\=[cda]\d\+\>.*/

syntax match flogDiffFile    contained /diff\>.*/
syntax match flogDiffFile    contained /+++ .*/
syntax match flogDiffFile    contained /Index: .*/
syntax match flogDiffFile    contained /==== .*/
syntax match flogDiffOldFile contained /\*\*\* .*/
syntax match flogDiffNewFile contained /--- .*/

syntax match flogDiffIndexLine contained /index \x\x\x\x.*/
syntax match flogDiffComment   contained /#.*/

" Link to original highlight groups
highlight default link flogDiffAdded     diffAdded
highlight default link flogDiffBDiffer   diffBDiffer
highlight default link flogDiffChanged   diffChanged
highlight default link flogDiffComment   diffComment
highlight default link flogDiffCommon    diffCommon
highlight default link flogDiffDiffer    diffDiffer
highlight default link flogDiffFile      diffFile
highlight default link flogDiffIdentical diffIdentical
highlight default link flogDiffIndexLine diffIndexLine
highlight default link flogDiffIsA       diffIsA
highlight default link flogDiffLine      diffLine
highlight default link flogDiffNewFile   diffNewFile
highlight default link flogDiffNoEOL     diffNoEOL
highlight default link flogDiffOldFile   diffOldFile
highlight default link flogDiffOnly      diffOnly
highlight default link flogDiffRemoved   diffRemoved

" Graph highlighting

if has('nvim') && g:flog_enable_dynamic_branch_hl
  if g:flog_enable_extended_chars
    syntax match flogBranches nextgroup=@flogCommitInfo,flogCollapsedCommit,@flogDiff /\v^%(%(%uf5d0|%uf5d1|%uf5d4|%uf5d6|%uf5d7|%uf5d8|%uf5d9|%uf5da|%uf5db|%uf5dd|%uf5de|%uf5e0|%uf5e1|%uf5e5|%uf5e6|%uf5ea|%uf5ef|%uf5f6|%uf5f7|%uf5f9|%uf5fa|%uf5fb| ).)*/
  else
    syntax match flogBranches nextgroup=@flogCommitInfo,flogCollapsedCommit,@flogDiff /\v^%(%(%u2022|%u2500|%u2502|%u250a|%u251c|%u2524|%u252c|%u2534|%u253c|%u256d|%u256e|%u256f|%u2570| ).)*/
  endif
else
  " Start of line, lead into branches or commit body
  syntax match flogLineStart nextgroup=@flogBranch1,@flogCommitInfo,flogCollapsedCommit,@flogDiff /^/

  " Cluster all branch 1 groups
  syntax cluster flogBranch1 contains=flogBranch1,flogBranch1Commit,flogBranch1MergeStart,flogBranch1MissingParentsStart

  let num_branch_colors = get(g:, 'flog_num_branch_colors', 8)

  " Dynamically generate highlight groups for branches
  for branch_idx in range(1, num_branch_colors)
    let branch = 'flogBranch' . branch_idx
    let merge = 'flogMerge' . branch_idx
    let next_branch_idx = branch_idx % num_branch_colors + 1
    let next_branch = 'flogBranch' . next_branch_idx
    let next_merge_branch = 'flogMerge' . branch_idx . 'Branch' . next_branch_idx

    " Support both flogGraphBranch* and flogBranch
    exec 'highlight link flogGraphBranch' . branch_idx . ' ' . branch

    " Branches at the start of the line - leads into other groups
    exec 'syntax match ' . branch . ' contained nextgroup=' . next_branch . ',' . next_branch . 'Commit,' . next_branch . 'MergeStart,' . next_branch . 'MissingParentsStart,flogCollapsedCommit,@flogDiff /\v  |%u2502 |%u2502$|%uf5d1 |%uf5d1$/'

    " Commit indicators
    exec 'syntax match ' . branch . 'Commit contained nextgroup=' . next_branch . 'AfterCommit,@flogCommitInfo /\v(%u2022|%uf5ef|%uf5f6|%uf5f7|%uf5f9|%uf5fa|%uf5fb) /'
    if g:flog_enable_extended_chars
      exec 'highlight link ' . branch . 'Commit ' . branch
    else
      exec 'highlight link ' . branch . 'Commit flogCommit'
    endif

    " Branches to the right of the commit indicator
    exec 'syntax match ' . branch . 'AfterCommit contained nextgroup=' . next_branch . 'AfterCommit,@flogCommitInfo /\v  |%u2502 |%u2502$|%uf5d1 |%uf5d1$/'
    exec 'highlight link ' . branch . 'AfterCommit ' . branch

    " Start of a merge - saves the branch that the merge starts on (see below)
    exec 'syntax match ' . branch . 'MergeStart contained nextgroup=' . next_merge_branch . ' /\v%u251c|%u256d|%u2570|%uf5da|%uf5db|%uf5d6|%uf5d8/'
    exec 'highlight link ' . branch . 'MergeStart ' . branch

    " Horizontal line inside of a merge
    exec 'syntax match ' . merge . 'Horizontal contained /\v%u2500|%uf5d0/'
    exec 'highlight link ' . merge . 'Horizontal ' . branch

    " Branches to the right of a merge
    exec 'syntax match ' . branch . 'AfterMerge contained nextgroup=' . next_branch . 'AfterMerge / ./'
    exec 'highlight link ' . branch . 'AfterMerge ' . branch

    " Start of missing parents line
    exec 'syntax match ' . branch . 'MissingParentsStart contained nextgroup=' . next_branch . 'MissingParents /\v%u250a |%uf5d4 /'
    exec 'highlight link ' . branch . 'MissingParentsStart ' . branch

    " Branches to right of missing parents start
    exec 'syntax match ' . branch . 'MissingParents contained nextgroup=' . next_branch . 'MissingParents /\v..|.$/'
    exec 'highlight link ' . branch . 'MissingParents ' . branch
  endfor

  " Dynamically generate highlight groups for merges
  for merge_idx in range(1, num_branch_colors)
    let merge = 'flogMerge' . merge_idx

    for branch_idx in range(1, num_branch_colors)
      let branch = 'flogBranch' . branch_idx
      let merge_branch = merge . 'Branch' . branch_idx
      let next_branch_idx = branch_idx % num_branch_colors + 1
      let next_branch = 'flogBranch' . next_branch_idx
      let next_merge_branch = merge . 'Branch' . next_branch_idx

      " Merge branches
      exec 'syntax match ' . merge_branch . ' contained contains=' . merge . 'Horizontal nextgroup=' . next_merge_branch . ',' . next_branch . 'AfterMerge /\v%u2500.|%uf5d0./'
      exec 'highlight link ' . merge_branch . ' ' . branch
    endfor
  endfor
endif

if &background ==# 'dark'
  highlight default flogBranch1 ctermfg=green       guifg=green1
  highlight default flogBranch2 ctermfg=yellow      guifg=yellow
  highlight default flogBranch3 ctermfg=darkmagenta guifg=orange1
  highlight default flogBranch4 ctermfg=red         guifg=indianred3
  highlight default flogBranch5 ctermfg=magenta     guifg=orchid1
  highlight default flogBranch6 ctermfg=darkred     guifg=purple1
  highlight default flogBranch7 ctermfg=blue        guifg=royalblue1
  highlight default flogBranch8 ctermfg=cyan        guifg=cyan2
else
  highlight default flogBranch1 ctermfg=darkgreen   guifg=green3
  highlight default flogBranch2 ctermfg=darkyellow  guifg=gold2
  highlight default flogBranch3 ctermfg=red         guifg=orange2
  highlight default flogBranch4 ctermfg=darkmagenta guifg=orangered3
  highlight default flogBranch5 ctermfg=darkred     guifg=deeppink2
  highlight default flogBranch6 ctermfg=magenta     guifg=darkviolet
  highlight default flogBranch7 ctermfg=darkblue    guifg=deepskyblue4
  highlight default flogBranch8 ctermfg=darkcyan    guifg=cyan3
endif

highlight link flogBranch0 flogBranch1
