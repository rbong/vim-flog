if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'floggraph'

runtime! syntax/diff.vim

syntax match flogLineStart nextgroup=@flogBranch1,@flogCommitInfo,flogCollapsedCommit,@flogDiff /^/

" Commit Highlighting

syntax cluster flogCommitInfo contains=flogHash,flogAuthor,flogRef,flogDate

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
exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v%(\d+ %(year|month|week|day|hour|minute|second)s? ago)%( |$)/'
" Human formats
exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v' . weekday_name_pattern . ' ' . iso_time_pattern . '%( |$)/'
exec 'syntax match flogDate contained nextgroup=flogHash,flogAuthor,flogRef /\v' . month_name_pattern . ' \d{1,2} \d{4}' . '%( |$)/'

highlight default link flogHash   Statement
highlight default link flogAuthor String
highlight default link flogRef    Directory
highlight default link flogDate   Number

" Collapsed commit indicator
syntax match flogCollapsedCommit contained /== \d\+ hidden lines ==$/

highlight default link flogCollapsedCommit Comment

" Ref Highlighting

syntax match flogRefTag    contained containedin=flogRef /\vtag: \zs.{-}\ze%(, |)\)/
syntax match flogRefRemote contained containedin=flogRef /\vremotes\/\zs.{-}\ze%(, |)\)/

highlight default link flogRefTag    String
highlight default link flogRefRemote Statement

syntax match flogRefHead       contained containedin=flogRef nextgroup=flogRefHeadArrow  /\<HEAD/
syntax match flogRefHeadArrow  contained                     nextgroup=flogRefHeadBranch / -> /
syntax match flogRefHeadBranch contained                                                 /[^,)]\+/

highlight default link flogRefHead       Keyword
highlight default link flogRefHeadArrow  flogRef
highlight default link flogRefHeadBranch Special

" Diff Highlighting
" Copied from syntax/diff.vim

syntax cluster flogDiff contains=flogDiffAdded,flogDiffBDiffer,flogDiffChanged,flogDiffComment,flogDiffCommon,flogDiffDiffer,flogDiffFile,flogDiffIdentical,flogDiffIndexLine,flogDiffIsA,flogDiffLine,flogDiffNewFile,flogDiffNoEOL,flogDiffOldFile,flogDiffOnly,flogDiffRemoved

syn match flogDiffOnly      contained /Only in .*/
syn match flogDiffIdentical contained /Files .* and .* are identical$/
syn match flogDiffDiffer    contained /Files .* and .* differ$/
syn match flogDiffBDiffer   contained /Binary files .* and .* differ$/
syn match flogDiffIsA       contained /File .* is a .* while file .* is a .*/
syn match flogDiffNoEOL     contained /\\ No newline at end of file .*/
syn match flogDiffCommon    contained /Common subdirectories: .*/

syn match flogDiffRemoved contained /-.*/
syn match flogDiffRemoved contained /<.*/
syn match flogDiffAdded   contained /+.*/
syn match flogDiffAdded   contained />.*/
syn match flogDiffChanged contained /! .*/

syn match flogDiffSubname contained containedin=flogDiffSubname /@@..*/ms=s+3
syn match flogDiffLine    contained /@.*/

syn match flogDiffLine contained /\*\*\*\*.*/
syn match flogDiffLine contained /---$/
syn match flogDiffLine contained /\d\+\%(,\d\+\)\=[cda]\d\+\>.*/

syn match flogDiffFile    contained /diff\>.*/
syn match flogDiffFile    contained /+++ .*/
syn match flogDiffFile    contained /Index: .*/
syn match flogDiffFile    contained /==== .*/
syn match flogDiffOldFile contained /\*\*\* .*/
syn match flogDiffNewFile contained /--- .*/

syn match flogDiffIndexLine contained /index \x\x\x\x.*/
syn match flogDiffComment   contained /#.*/

" Link to original highlight groups
hi default link flogDiffAdded     diffAdded
hi default link flogDiffBDiffer   diffBDiffer
hi default link flogDiffChanged   diffChanged
hi default link flogDiffComment   diffComment
hi default link flogDiffCommon    diffCommon
hi default link flogDiffDiffer    diffDiffer
hi default link flogDiffFile      diffFile
hi default link flogDiffIdentical diffIdentical
hi default link flogDiffIndexLine diffIndexLine
hi default link flogDiffIsA       diffIsA
hi default link flogDiffLine      diffLine
hi default link flogDiffNewFile   diffNewFile
hi default link flogDiffNoEOL     diffNoEOL
hi default link flogDiffOldFile   diffOldFile
hi default link flogDiffOnly      diffOnly
hi default link flogDiffRemoved   diffRemoved

" Graph Highlighting

" Cluster all branch 1 groups
syntax cluster flogBranch1 contains=flogBranch1,flogBranch1Commit,flogBranch1MergeStart,flogBranch1ComplexMergeStart,flogBranch1MissingParentsStart

" Dynamically generate highlight groups for branches
for branch_idx in range(1, 9)
  let branch = 'flogBranch' . branch_idx
  let merge = 'flogMerge' . branch_idx
  let next_branch_idx = branch_idx % 9 + 1
  let next_branch = 'flogBranch' . next_branch_idx
  let next_merge_branch = 'flogMerge' . branch_idx . 'Branch' . next_branch_idx

  " Support both flogGraphBranch* and flogBranch
  exec 'highlight link flogGraphBranch' . branch_idx . ' ' . branch

  " Branches at the start of the line - leads into other groups
  exec 'syntax match ' . branch . ' contained nextgroup=' . next_branch . ',' . next_branch . 'Commit,' . next_branch . 'MergeStart,' . next_branch . 'ComplexMergeStart,' . next_branch . 'MissingParentsStart,flogCollapsedCommit,@flogDiff /\v%(  |%u2502 |%u2502$)/'

  " Commit indicators
  exec 'syntax match ' . branch . 'Commit contained nextgroup=' . next_branch . 'AfterCommit,@flogCommitInfo /\%u2022 /'
  exec 'highlight link ' . branch . 'Commit flogCommit'

  " Branches to the right of the commit indicator
  exec 'syntax match ' . branch . 'AfterCommit contained nextgroup=' . next_branch . 'AfterCommit,@flogCommitInfo /\v%(  |%u2502 |%u2502$)/'
  exec 'highlight link ' . branch . 'AfterCommit ' . branch

  " Start of a merge - saves the branch that the merge starts on (see below)
  exec 'syntax match ' . branch . 'MergeStart contained nextgroup=' . next_merge_branch . ',' . next_merge_branch . 'End /\v%(%u251c|%u256d|%u2570)/'
  exec 'highlight link ' . branch . 'MergeStart ' . branch

  " Horizontal merge character
  exec 'syntax match ' . merge . 'Horizontal contained /\v%(%u2500|%u252c|%u2534|%u256e|%u256f)/'
  exec 'highlight link ' . merge . 'Horizontal ' . branch

  " Branches to the right of a merge
  exec 'syntax match ' . branch . 'AfterMerge contained nextgroup=' . next_branch . 'AfterMerge /\v%(  | %u2502|)/'
  exec 'highlight link ' . branch . 'AfterMerge ' . branch

  " Start of complex merge line
  exec 'syntax match ' . branch . 'ComplexMergeStart contained nextgroup=' . next_branch . 'ComplexMerge /\v%( |%u2502)\ze%u2570%u2524/'
  exec 'highlight link ' . branch . 'ComplexMergeStart ' . branch

  " Branches to right of complex merge line start
  exec 'syntax match ' . branch . 'ComplexMerge contained nextgroup=' . next_branch . 'ComplexMerge /\v%(  | %u2502|%u2570%u2524)/'
  exec 'highlight link ' . branch . 'ComplexMerge ' . branch

  " Start of missing parents line
  exec 'syntax match ' . branch . 'MissingParentsStart contained nextgroup=' . next_branch . 'MissingParents /\v%u250a /'
  exec 'highlight link ' . branch . 'MissingParentsStart ' . branch

  " Branches to right of missing parents start
  exec 'syntax match ' . branch . 'MissingParents contained nextgroup=' . next_branch . 'MissingParents /\v%(  |%u2502 |%u2502$|%u250a |%u250a$)/'
  exec 'highlight link ' . branch . 'MissingParents ' . branch
endfor

" Dynamically generate highlight groups for merges
for merge_idx in range(1, 9)
  let merge = 'flogMerge' . merge_idx

  for branch_idx in range(1, 9)
    let branch = 'flogBranch' . branch_idx
    let merge_branch = merge . 'Branch' . branch_idx
    let next_branch_idx = branch_idx % 9 + 1
    let next_branch = 'flogBranch' . next_branch_idx
    let next_merge_branch = merge . 'Branch' . next_branch_idx

    " Merge branches
    exec 'syntax match ' . merge_branch . ' contained contains=' . merge . 'Horizontal nextgroup=' . next_merge_branch ',' . next_merge_branch . 'End /\v%(%u2500|%u252c)\v%(%u2500|%u252c|%u2534|%u250a|%u253c)/'
    exec 'highlight link ' . merge_branch . ' ' . branch

    " End of a merge - lead into a simplified highlight group
    exec 'syntax match ' . merge_branch . 'End contained contains=' . merge . 'Horizontal nextgroup=' . next_branch . 'AfterMerge /\v%u2500%(%u2524|%u256e|%u256f)/'
    exec 'highlight link ' . merge_branch . 'End ' . branch
  endfor
endfor

if &background ==# 'dark'
  highlight default flogBranch1 ctermfg=magenta guifg=green1
  highlight default flogBranch2 ctermfg=green   guifg=yellow1
  highlight default flogBranch3 ctermfg=yellow  guifg=orange1
  highlight default flogBranch4 ctermfg=cyan    guifg=greenyellow
  highlight default flogBranch5 ctermfg=red     guifg=springgreen1
  highlight default flogBranch6 ctermfg=yellow  guifg=cyan1
  highlight default flogBranch7 ctermfg=green   guifg=slateblue1
  highlight default flogBranch8 ctermfg=cyan    guifg=magenta1
  highlight default flogBranch9 ctermfg=magenta guifg=purple1
else
  highlight default flogBranch1 ctermfg=darkyellow  guifg=orangered3
  highlight default flogBranch2 ctermfg=darkgreen   guifg=orange2
  highlight default flogBranch3 ctermfg=blue        guifg=yellow3
  highlight default flogBranch4 ctermfg=darkmagenta guifg=olivedrab4
  highlight default flogBranch5 ctermfg=red         guifg=green4
  highlight default flogBranch6 ctermfg=darkyellow  guifg=paleturquoise3
  highlight default flogBranch7 ctermfg=darkgreen   guifg=deepskyblue4
  highlight default flogBranch8 ctermfg=blue        guifg=darkslateblue
  highlight default flogBranch9 ctermfg=darkmagenta guifg=darkviolet
endif

highlight link flogBranch0 flogBranch1
