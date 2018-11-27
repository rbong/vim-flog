if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'floggraph'

" Graph {{{

syntax match flogGraphEdge9 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge0 skipwhite
syntax match flogGraphEdge8 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge9 skipwhite
syntax match flogGraphEdge7 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge8 skipwhite
syntax match flogGraphEdge6 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge7 skipwhite
syntax match flogGraphEdge5 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge6 skipwhite
syntax match flogGraphEdge4 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge5 skipwhite
syntax match flogGraphEdge3 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge4 skipwhite
syntax match flogGraphEdge2 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge3 skipwhite
syntax match flogGraphEdge1 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge2 skipwhite
syntax match flogGraphEdge0 /_\?\(|\|-\(-\|\.\)\|\/|\?\|\\\|\*\|+\|=\)\s\?/ nextgroup=flogGraphEdge1 skipwhite
syntax match flogGraphEdgeH /_/ contained containedin=flogGraphEdge0,flogGraphEdge1,flogGraphEdge2,flogGraphEdge3,flogGraphEdge4,flogGraphEdge5,flogGraphEdge6,flogGraphEdge7,flogGraphEdge8,flogGraphEdge9

highlight default link flogGraphEdge0 Delimiter

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
