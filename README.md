# Flog

[![test status](https://github.com/rbong/vim-flog/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/rbong/vim-flog/actions)

Flog is a fast, beautiful, and powerful git branch viewer for Vim.

![flog in action](img/screen-graph.png)

## Prerequisites

In Vim 8/9, [LuaJIT 2.1](https://luajit.org/download.html) must be installed.

On systems without LuaJIT available, you may also use [Lua](https://www.lua.org/) 5.1,
however this is less performant.

Neovim is supported natively.

## Installation

If you use [Plug](https://github.com/junegunn/vim-plug), add the following to your `.vimrc`:

```vim
Plug 'tpope/vim-fugitive'
Plug 'rbong/vim-flog'
```

## Using Flog

Open the git branch graph with `:Flog` or `:Flogsplit`.
Many options can be passed in, complete with `<Tab>` completion.

Open commits in temporary windows once you've opened Flog using `<CR>`.
Jump between commits with `<C-N>` and `<C-P>`.

Refresh the git branch graph with `u`.
Toggle viewing all branches with `a`.
Toggle displaying no merges with `gm`.
Toggle viewing the reflog with `gr`.
Toggle bisect mode with `gb`.
Quit with `gq`.

See more mappings with `g?`.

Many of the mappings that work in the Fugitive `:Git` status window will work in Flog.

Run `:Git` commands in a split next to the git branch graph using `:Floggit -p`.
Command line completion is provided to do any git command with the commits and refs under the cursor.

Flog can be heavily customized with functions.
See [examples](EXAMPLES.md) for details.

## Getting Help

See [the issue tracker](https://github.com/rbong/vim-flog/issues) and `:help flog`.

See [fugitive](https://github.com/tpope/vim-fugitive) for help with fugitive.

See `git log --help` for help with `git log`.

More info:
- [FAQ](FAQ.md)
- [Examples](EXAMPLES.md)
- [Contributing](CONTRIBUTING.md)
