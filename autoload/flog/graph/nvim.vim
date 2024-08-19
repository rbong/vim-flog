"
" This file contains functions for generating the commit graph in Neovim.
"

function! flog#graph#nvim#Get(git_cmd) abort
  let l:state = flog#state#GetBufState()

  return v:lua.require('flog/graph').get_graph(
        \ l:state.instance_number,
        \ v:false,
        \ v:true,
        \ v:true,
        \ g:flog_commit_start_token,
        \ g:flog_enable_extended_chars ? v:true : v:false,
        \ g:flog_enable_extra_padding ? v:true : v:false,
        \ state.opts.graph ? v:true : v:false,
        \ state.opts.default_collapsed ? v:true : v:false,
        \ a:git_cmd,
        \ l:state.collapsed_commits
        \ )
endfunction

function! flog#graph#nvim#Update(graph) abort
  let l:state = flog#state#GetBufState()

  return v:lua.require('flog/graph').update_graph(
        \ l:state.instance_number,
        \ v:true,
        \ l:state.opts.default_collapsed ? v:true : v:false,
        \ a:graph,
        \ l:state.collapsed_commits
        \ )
endfunction
