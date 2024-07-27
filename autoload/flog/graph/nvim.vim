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
        \ state.opts.default_collapsed ? v:true : v:false,
        \ a:git_cmd,
        \ l:state.collapsed_commits
        \ )
endfunction

function! flog#graph#nvim#Update(graph) abort
  " Normally Lua is faster, but Neovim copies all objects so it's much slower
  " let l:state = flog#state#GetBufState()

  " let l:graph_lib = flog#lua#GetLibPath('graph.lua')
  " exec 'luafile ' . fnameescape(l:graph_lib)

  " return v:lua.flog_update_graph(
  "       \ v:true,
  "       \ l:state.opts.default_collapsed ? v:true : v:false,
  "       \ a:graph,
  "       \ l:state.collapsed_commits
  "       \ )

  " HACK: copy of flog#graph#vim#Update in legacy vimscript (slow)

  call flog#floggraph#buf#AssertFlogBuf()
  let l:state = flog#state#GetBufState()

  let l:collapsed_commits = l:state.collapsed_commits
  let l:default_collapsed = l:state.opts.default_collapsed

  " Init data
  let l:commits = a:graph.commits
  let l:commit_index = 0
  let l:commits_by_hash = a:graph.commits_by_hash
  let l:line_commits = []
  let l:output = []
  let l:total_lines = 0

  " Find number of commits
  let l:ncommits = len(l:commits)

  " Rebuild output/line commits
  while l:commit_index < l:ncommits
    let l:commit = l:commits[l:commit_index]
    let l:hash = l:commit.hash
    let len = l:commit.len
    let suffix_len = l:commit.suffix_len

    " Record commit
    let l:commits_by_hash[l:hash] = l:commit

    " Update line position
    let l:commit.line = l:total_lines + 1

    " Add subject
    call add(l:output, l:commit.subject)
    call add(l:line_commits, l:commit)
    let l:total_lines += 1

    if len > 1
      if get(l:collapsed_commits, l:hash, l:default_collapsed)
        " Add collapsed body
        call add(l:output, l:commit.collapsed_body)
        call add(l:line_commits, l:commit)
        let l:total_lines += 1
      else
        " Add body
        let l:body_index = 0
        let l:body = l:commit.body
        while l:body_index < len - 1
          call add(l:output, l:body[l:body_index])
          call add(l:line_commits, l:commit)
          let l:body_index += 1
        endwhile
        let l:total_lines += len - 1
      endif
    endif

    if suffix_len > 0
      " Add suffix
      let l:suffix_index = 0
      let l:suffix = l:commit.suffix
      while l:suffix_index <= suffix_len - 1
        call add(l:output, l:suffix[l:suffix_index])
        call add(l:line_commits, l:commit)
        let l:suffix_index += 1
      endwhile
      let l:total_lines += suffix_len
    endif

    " Increment
    let l:commit_index += 1
  endwhile

  return {
        \ 'output': l:output,
        \ 'commits': l:commits,
        \ 'commits_by_hash': l:commits_by_hash,
        \ 'line_commits': l:line_commits,
        \ }
endfunction
