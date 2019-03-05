# Flog

Flog is a lightweight and powerful git branch viewer that integrates with
[fugitive](https://github.com/tpope/vim-fugitive).

![flog in action](img/screen-graph.png)

## Installation

Using [Plug](https://github.com/junegunn/vim-plug), add `Plug 'rbong/vim-flog'` to your `.vimrc`.
See `:help plug-example` for more information.
You must also install [fugitive](https://github.com/tpope/vim-fugitive).
If you do not use plug, see your plugin manager of choice's documentation.

## Using Flog

Open the commit graph with `:Flog` or `:Flogsplit`.
Many options can be passed in, complete with `<Tab>` completion.

Preview commits once you've opened Flog using `<CR>`.
Jump between commits with `<C-N>` and `<C-P>`.

Refresh the graph with `u`.
Toggle viewing all branches with `a`.
Toggle bisect mode with `gb`.
Toggle displaying no merges with `gm`.
Quit with `ZZ`.

Run `:Git` commands in a split next to the graph using `:Floggit!`.
Command line completion is provided to do any git command with the commits and refs under the cursor.

## Getting Help

If you have questions, requests, or bugs, see
[the issue tracker](https://github.com/rbong/issues) and `:help flog`.

Please see [fugitive](https://github.com/tpope/vim-fugitive) for help with Fugitive commands.
See `man git-log` for any problems specific to `git log`.

## Contributing

Before contributing please see [CONTRIBUTING.md](CONTRIBUTING.md).
