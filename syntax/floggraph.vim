if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'floggraph'

runtime! syntax/diff.vim

syntax match flogEmptyStart /^/ nextgroup=@flogDiff,@flogCommitInfo

" Commit Highlighting

syntax match flogCommitInfo contained nextgroup=@flogCommitInfo /\v%(%U1f784.{-})@<= /
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

syntax match flogDiff contained nextgroup=@flogDiff /\v%(%U1f784.*)@<! /
syntax cluster flogDiff contains=flogDiffAdded,flogDiffBDiffer,flogDiffChanged,flogDiffComment,flogDiffCommon,flogDiffDiffer,flogDiffFile,flogDiffIdentical,flogDiffIndexLine,flogDiffIsA,flogDiffLine,flogDiffNewFile,flogDiffNoEOL,flogDiffOldFile,flogDiffOnly,flogDiffRemoved

syntax match flogDiffEmptyStart /^ \+/ nextgroup=@flogDiff

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

" Entry point for branches
syntax match flogGraphBranch0 nextgroup=flogGraphBranch2,flogDiff,flogCommitInfo /\v^%( |%u2502|%u250a|%u251c|%u256d|%u2570|%U1f784)/

" Color cycle for branches
let branch_pattern = '/\v%( |%u2500|%u252c|%u2570)%( |%u2500|%u2502|%u250a|%u251c|%u2524|%u252c|%u2534|%u253c|%u256d|%u256e|%u256f|%u2570|%U1f784)/'
exec 'syntax match flogGraphBranch9 contained nextgroup=flogGraphBranch1,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch8 contained nextgroup=flogGraphBranch9,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch7 contained nextgroup=flogGraphBranch8,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch6 contained nextgroup=flogGraphBranch7,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch5 contained nextgroup=flogGraphBranch6,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch4 contained nextgroup=flogGraphBranch5,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch3 contained nextgroup=flogGraphBranch4,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch2 contained nextgroup=flogGraphBranch3,flogDiff,flogCommitInfo ' . branch_pattern
exec 'syntax match flogGraphBranch1 contained nextgroup=flogGraphBranch2,flogDiff,flogCommitInfo ' . branch_pattern

syntax cluster flogGraphBranch contains=flogGraphBranch0,flogGraphBranch1,flogGraphBranch2,flogGraphBranch3,flogGraphBranch4,flogGraphBranch5,flogGraphBranch6,flogGraphBranch7,flogGraphBranch8,flogGraphBranch9

syntax match flogGraphCommit /\v%U1f784/ contained containedin=@flogGraphBranch
syntax match flogGraphMerge /\v%(%u2500|%u252c\ze%U1f784|%u2534)/ contained containedin=@flogGraphBranch

if &background ==# 'dark'
  highlight default flogGraphBranch1 ctermfg=magenta     guifg=green1
  highlight link    flogGraphBranch0 flogGraphBranch1
  highlight default flogGraphBranch2 ctermfg=green       guifg=yellow1
  highlight default flogGraphBranch3 ctermfg=yellow      guifg=orange1
  highlight default flogGraphBranch4 ctermfg=cyan        guifg=greenyellow
  highlight default flogGraphBranch5 ctermfg=red         guifg=springgreen1
  highlight default flogGraphBranch6 ctermfg=yellow      guifg=cyan1
  highlight default flogGraphBranch7 ctermfg=green       guifg=slateblue1
  highlight default flogGraphBranch8 ctermfg=cyan        guifg=magenta1
  highlight default flogGraphBranch9 ctermfg=magenta     guifg=purple1
else
  highlight default flogGraphBranch1 ctermfg=darkyellow  guifg=orangered3
  highlight default flogGraphBranch2 ctermfg=darkgreen   guifg=orange2
  highlight default flogGraphBranch3 ctermfg=blue        guifg=yellow3
  highlight default flogGraphBranch4 ctermfg=darkmagenta guifg=olivedrab4
  highlight default flogGraphBranch5 ctermfg=red         guifg=green4
  highlight default flogGraphBranch6 ctermfg=darkyellow  guifg=paleturquoise3
  highlight default flogGraphBranch7 ctermfg=darkgreen   guifg=deepskyblue4
  highlight default flogGraphBranch8 ctermfg=blue        guifg=darkslateblue
  highlight default flogGraphBranch9 ctermfg=darkmagenta guifg=darkviolet
endif
