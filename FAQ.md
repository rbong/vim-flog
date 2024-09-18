# Flog FAQ

## Why does Flog hang the first time I run it?

The first time Flog runs for a repo, it runs `git commit-graph write`.
This ultimately makes it run faster.

Disable this feature:

```
let g:flog_write_commit_graph = 0
```

Set args (defaults shown):

```
let g:flog_write_commit_graph_args = ['--reachable', '--progress']
```

## Why is Flog getting slower over time for me?

The commit graph will eventually become out of date.

You can update it by running:

```
git commit-graph write --reachable --progress
```

## How do I reduce the number of commits?

Flog will shows 5,000 commits by default.

Show 2,000 commits one time:

```
:Flog -max-count=2000
```

Show 2,000 commits by default:

```
let g:flog_permanent_default_opts = { 'max_count': 2000 }
```

## How can I disable the graph and show only commits?

Toggle the graph with `gx` or launch with `:Flog -no-graph`.

## What are the differences with other branch viewers?

**gv.vim**

[gv.vim](https://github.com/junegunn/gv.vim) is an ultra-light branch viewer.
It is not very customizable by design.

Flog is more fully featured than gv.vim and has nicer looking branches and highlighting.
Flog has comparable speed to gv.vim, but is more complex.

**gitv**

[gitv](https://github.com/gregsexton/gitv) is also a fully featured branch viewer.

However, gitv however is not maintained.
Flog aims to be a successor to gitv and is improved in every practical way.

**gitgraph.nvim**

[gitgraph.nvim](https://github.com/isakbm/gitgraph.nvim) is a fully featured Neovim branch viewer still under development.

Flog may be slower than gitgraph.nvim when scrolling in large repos on weaker machines.
As a tradeoff, gitgraph.nvim has better scrolling performance, but has exponentially worse loading time and memory use.

Flog's branch representation is more straightforward.
gitgraph.nvim has an opinionated branch drawing algorithm, but currently, any potential advantages are undocumented.

Flog is an extension for [fugitive.vim](https://github.com/tpope/vim-fugitive).
gitgraph.nvim has hooks for plugins like [diffview](https://github.com/sindrets/diffview.nvim).

Flog has features that have no equivalent in gitgraph.nvim, such as commit marks, some navigation mappings, and contextually aware command completion.

gitgraph.nvim is written in pure Lua.
Flog supports both Vim and Neovim, so it uses both Vimscript and Lua.

Flog and gitgraph.nvim are both well written.
Flog's code has aggressive optimizations and legacy support, so gitgraph.nvim currently has cleaner code.

Both plugins have test coverage but have different testing philosophies.

## How can I learn how to use flog?

See `:help flog` for all commands and options.
See [examples](EXAMPLES.md) for detailed walkthroughs.
Please [start a discussion](https://github.com/rbong/vim-flog/discussions/new/choose) if you have any questions or [post an issue](https://github.com/rbong/vim-flog/issues/) if you run into any bugs.
