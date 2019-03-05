if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'floggraph'

" Commit {{{

syntax match flogCommit /.*/
syntax match flogHash   contained containedin=flogCommit /\s\zs\[[0-9a-f]\+\]/
syntax match flogAuthor contained containedin=flogCommit /\s\zs{[^}].*}/
syntax match flogRef    contained containedin=flogCommit /\s\zs([^)].*)/
syntax match flogDate   contained containedin=flogCommit /\s\d\{4}-\d\d-\d\d\( \d\d:\d\d\(:\d\d\( [+-][0-9]\{4}\)\?\)\)\?/

highlight default link flogHash   Statement
highlight default link flogAuthor String
highlight default link flogRef    Directory
highlight default link flogDate   Number

" Ref {{{

syntax match flogRefTag    contained containedin=flogRef /tags\/\zs.\{-}\ze\(, \|)\)/
syntax match flogRefRemote contained containedin=flogRef /remotes\/\zs.\{-}\ze\(, \|)\)/
syntax match flogRefHead   contained containedin=flogRef /HEAD/

highlight default link flogRefTag    String
highlight default link flogRefRemote Statement
highlight default link flogRefHead   Special

" }}}

" }}}

" Graph {{{

" these syntax regex match all possible graph characters
" they will match one vertical column of graph characters from left to right ignoring whitespace
" this makes all graph characters in a column highlighted in the same way
syntax match flogGraphEdge9 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge1,flogCommit skipwhite
syntax match flogGraphEdge8 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge9,flogCommit skipwhite
syntax match flogGraphEdge7 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge8,flogCommit skipwhite
syntax match flogGraphEdge6 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge7,flogCommit skipwhite
syntax match flogGraphEdge5 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge6,flogCommit skipwhite
syntax match flogGraphEdge4 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge5,flogCommit skipwhite
syntax match flogGraphEdge3 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge4,flogCommit skipwhite
syntax match flogGraphEdge2 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge3,flogCommit skipwhite
syntax match flogGraphEdge1 /[_/ ]\?[|/\\*]/ nextgroup=flogGraphEdge2,flogCommit skipwhite
syntax match flogGraphEdgeH /_\|\/\ze|/ contained containedin=flogGraphEdge1,flogGraphEdge2,flogGraphEdge3,flogGraphEdge4,flogGraphEdge5,flogGraphEdge6,flogGraphEdge7,flogGraphEdge8,flogGraphEdge9

if &background ==# 'dark'
  highlight default flogGraphEdge1 ctermfg=magenta     guifg=green1
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
