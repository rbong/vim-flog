"
" This file contains functions for generating the commit graph in Neovim.
"

function! flog#graph#nvim#Get(git_cmd) abort
  let l:state = flog#state#GetBufState()

  let l:graph_lib = flog#lua#GetLibPath('graph.lua')
  exec 'luafile ' . fnameescape(l:graph_lib)

  return v:lua.flog_get_graph(
        \ v:false,
        \ v:true,
        \ v:true,
        \ g:flog_commit_start_token,
        \ state.opts.graph ? v:true : v:false,
        \ a:git_cmd
        \ )
endfunction
