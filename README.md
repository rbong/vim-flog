# Flog

[![Build Status](https://travis-ci.org/rbong/vim-flog.svg?branch=master)](https://travis-ci.org/rbong/vim-flog)

Flog is a lightweight and powerful git branch viewer that integrates with
[fugitive](https://github.com/tpope/vim-fugitive).

![flog in action](img/screen-graph.png)

## Installation

Using [Plug](https://github.com/junegunn/vim-plug) add the following to your `.vimrc`:

```vim
Plug 'tpope/vim-fugitive'
Plug 'rbong/vim-flog'
```

See `:help plug-example` for more information.
If you do not use plug, see your plugin manager of choice's documentation.

Requires vim version 7.4.2204 or greater.
Neovim is also supported.

## Using Flog

Open the commit graph with `:Flog` or `:Flogsplit`.
Many options can be passed in, complete with `<Tab>` completion.

Open commits in temporary windows once you've opened Flog using `<CR>`.
Jump between commits with `<C-N>` and `<C-P>`.

Refresh the graph with `u`.
Toggle viewing all branches with `a`.
Toggle bisect mode with `gb`.
Toggle displaying no merges with `gm`.
Toggle viewing the reflog with `gr`.
Quit with `gq`.

Many of the bindings that work in fugitive in `:Gstatus` windows will work in Flog.

To see more bindings or get a refresher, press `g?`.

Run `:Git` commands in a split next to the graph using `:Floggit -p`.
Command line completion is provided to do any git command with the commits and refs under the cursor.

## Custom bindings

Intead of trying to provide settings for everything, vim-flog provides utility functions and leaves
keybindings and customization to your vimrc. If you'd like to see all of the functions available, see
[autoload/flog.vim](https://github.com/rbong/vim-flog/blob/master/autoload/flog.vim). If you'd like
some examples of how commands use these functions, check out 
[ftplugin/floggraph.vim](https://github.com/rbong/vim-flog/blob/master/autoload/flog.vim).
If you'd like me to change or provide a utility function, 
[open an issue](https://github.com/rbong/vim-flog/issues/new/choose) to let me know.

Below is some example configuration you could add to your vimrc, to get you started.
Since the git history buffer isn't modifiable, it makes sense to start bindings with e.g.
`c`, `D`, `R` which normally refer to buffer modification operations.

```
" Open flog, pass -all to show all branches by default (toggle by pressing 'a')
nnoremap <Leader>nl :Flog -all<CR>

augroup flog
  " Diff down below; pressing <CR> on a commit by default opens a split to the right
  autocmd FileType floggraph nno <buffer> D :<C-U>call flog#run_tmp_command('below Git diff HEAD %h')<CR>

  " D for diff between visually selected commits, just like cntrl-clicking two commits in GitExtensions
  autocmd FileType floggraph vno <buffer> D :<C-U>call flog#run_tmp_command("below Git diff %(h'>) %(h'<)")<CR>
  " D Downwards is the diff going from the top commit to the bottom one
  autocmd FileType floggraph vno <buffer> DD :<C-U>call flog#run_tmp_command("below Git diff %(h'<) %(h'>)")<CR>

  " Create a new fixup commit targeting the selected one. A subsequent rebase with `ri` will automatically 
  autocmd FileType floggraph nno <buffer> cf :<C-U>call flog#run_command('Git commit -m "fixup! %h"', 0, 1)<CR>

  " Resetting to selected commit
  autocmd FileType floggraph nno <buffer> cv :<C-U>call flog#run_command("Git reset --mixed %h", 0, 1)<CR>
  autocmd FileType floggraph nno <buffer> cV :<C-U>call flog#run_command("Git reset --hard %h", 0, 1)<CR>

  " Merge the highlighted branch
  autocmd FileType floggraph nno <buffer> cm :<C-U>call flog#run_command('Git merge %l --no-ff', 0, 1)<CR>

  " Rebind the default ref-jumping to just jump, not also open a split
  autocmd FileType floggraph nno <buffer> <silent> ]r :<C-U>call flog#next_ref()<CR>
  autocmd FileType floggraph nno <buffer> <silent> [r :<C-U>call flog#previous_ref()<CR>
augroup END

let g:flog_default_arguments = { 'date' : 'short' }
```

## Getting Help

If you have questions, requests, or bugs, see
[the issue tracker](https://github.com/rbong/vim-flog/issues) and `:help flog`.

Please see [fugitive](https://github.com/tpope/vim-fugitive) for help with Fugitive commands.
See `git log --help` for any problems specific to `git log`.

More info:
- [FAQ](FAQ.md)
- [Examples](EXAMPLES.md)
- [Contributing](CONTRIBUTING.md)
