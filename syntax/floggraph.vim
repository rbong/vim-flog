if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'floggraph'

if get(g:, 'flog_use_ansi_esc')
  finish
endif

runtime! syntax/diff.vim

" Commit {{{

syntax match flogHash   / \[[0-9a-f]\+\]/
syntax match flogAuthor / {[^}].*}/
syntax match flogRef    / (\([^)~\\:^]\|tag:\)\+)/
syntax match flogDate   /\v<\zs\d{4}-\d\d-\d\d( \d\d:\d\d(:\d\d( [+-]\d{4})?)?)?/

highlight default link flogHash   Statement
highlight default link flogAuthor String
highlight default link flogRef    Directory
highlight default link flogDate   Number

" Ref {{{

syntax match flogRefTag    contained containedin=flogRef /\vtag: \zs.{-}\ze(, |)\)/
syntax match flogRefRemote contained containedin=flogRef /\vremotes\/\zs.{-}\ze(, |)\)/

highlight default link flogRefTag    String
highlight default link flogRefRemote Statement

syntax match flogRefHead       contained containedin=flogRef nextgroup=flogRefHeadArrow  /\<HEAD/
syntax match flogRefHeadArrow  contained                     nextgroup=flogRefHeadBranch / -> /
syntax match flogRefHeadBranch contained                                                 /[^,)]\+/

highlight default link flogRefHead       Keyword
highlight default link flogRefHeadArrow  flogRef
highlight default link flogRefHeadBranch Special

" }}}

" Diff {{{

syntax cluster flogDiff contains=flogDiffAdded,flogDiffBDiffer,flogDiffChanged,flogDiffComment,flogDiffCommon,flogDiffDiffer,flogDiffFile,flogDiffIdentical,flogDiffIndexLine,flogDiffIsA,flogDiffLine,flogDiffNewFile,flogDiffNoEOL,flogDiffOldFile,flogDiffOnly,flogDiffRemoved

syntax match flogEmptyStart /^ \+\ze / nextgroup=@flogDiff

" copied from syntax/diff.vim

syn match flogDiffOnly      contained / Only in .*/
syn match flogDiffIdentical contained / Files .* and .* are identical$/
syn match flogDiffDiffer    contained / Files .* and .* differ$/
syn match flogDiffBDiffer   contained / Binary files .* and .* differ$/
syn match flogDiffIsA       contained / File .* is a .* while file .* is a .*/
syn match flogDiffNoEOL     contained / \\ No newline at end of file .*/
syn match flogDiffCommon    contained / Common subdirectories: .*/

syn match flogDiffRemoved contained / -.*/
syn match flogDiffRemoved contained / <.*/
syn match flogDiffAdded   contained / +.*/
syn match flogDiffAdded   contained / >.*/
syn match flogDiffChanged contained / ! .*/

syn match flogDiffSubname contained containedin=flogDiffSubname / @@..*/ms=s+3
syn match flogDiffLine    contained / @.*/

syn match flogDiffLine contained / \*\*\*\*.*/
syn match flogDiffLine contained / ---$/
syn match flogDiffLine contained / \d\+\(,\d\+\)\=[cda]\d\+\>.*/

syn match flogDiffFile    contained / diff\>.*/
syn match flogDiffFile    contained / +++ .*/
syn match flogDiffFile    contained / Index: .*/
syn match flogDiffFile    contained / ==== .*/
syn match flogDiffOldFile contained / \*\*\* .*/
syn match flogDiffNewFile contained / --- .*/

syn match flogDiffIndexLine contained / index \x\x\x\x.*/
syn match flogDiffComment   contained / #.*/

" link to original highlight groups

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

" }}}

" }}}

" Graph {{{

" these syntax regex match all possible graph characters
" they will match one vertical column of graph characters from left to right ignoring whitespace
" this makes all graph characters in a column highlighted in the same way
syntax match flogGraphEdge9 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge1,@flogDiff contained
syntax match flogGraphEdge8 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge9,@flogDiff contained
syntax match flogGraphEdge7 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge8,@flogDiff contained
syntax match flogGraphEdge6 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge7,@flogDiff contained
syntax match flogGraphEdge5 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge6,@flogDiff contained
syntax match flogGraphEdge4 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge5,@flogDiff contained
syntax match flogGraphEdge3 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge4,@flogDiff contained
syntax match flogGraphEdge2 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge3,@flogDiff contained
syntax match flogGraphEdge1 /[_/ ]\?[|/\\*]/  nextgroup=flogGraphEdge2,@flogDiff contained
syntax match flogGraphEdge0 /^[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge2,@flogDiff

syntax cluster flogGraphEdge contains=flogGraphEdge0,flogGraphEdge1,flogGraphEdge2,flogGraphEdge3,flogGraphEdge4,flogGraphEdge5,flogGraphEdge6,flogGraphEdge7,flogGraphEdge8,flogGraphEdge9

syntax match flogGraphCrossing /_\|\/\ze|/ contained containedin=@flogGraphEdge
syntax match flogGraphCommit /\*/ contained containedin=@flogGraphEdge

if &background ==# 'dark'
  highlight default flogGraphEdge1 ctermfg=magenta     guifg=green1
  highlight link    flogGraphEdge0 flogGraphEdge1
  highlight default flogGraphEdge2 ctermfg=green       guifg=yellow1
  highlight default flogGraphEdge3 ctermfg=yellow      guifg=orange1
  highlight default flogGraphEdge4 ctermfg=cyan        guifg=greenyellow
  highlight default flogGraphEdge5 ctermfg=red         guifg=springgreen1
  highlight default flogGraphEdge6 ctermfg=yellow      guifg=cyan1
  highlight default flogGraphEdge7 ctermfg=green       guifg=slateblue1
  highlight default flogGraphEdge8 ctermfg=cyan        guifg=magenta1
  highlight default flogGraphEdge9 ctermfg=magenta     guifg=purple1
else
  highlight default flogGraphEdge1 ctermfg=darkyellow  guifg=orangered3
  highlight default flogGraphEdge2 ctermfg=darkgreen   guifg=orange2
  highlight default flogGraphEdge3 ctermfg=blue        guifg=yellow3
  highlight default flogGraphEdge4 ctermfg=darkmagenta guifg=olivedrab4
  highlight default flogGraphEdge5 ctermfg=red         guifg=green4
  highlight default flogGraphEdge6 ctermfg=darkyellow  guifg=paleturquoise3
  highlight default flogGraphEdge7 ctermfg=darkgreen   guifg=deepskyblue4
  highlight default flogGraphEdge8 ctermfg=blue        guifg=darkslateblue
  highlight default flogGraphEdge9 ctermfg=darkmagenta guifg=darkviolet
endif

" }}}

" vim: set et sw=2 ts=2 fdm=marker:
