# Flog FAQ

## How do I get Flog to run faster?

The answer depends on your issue.

**Flog is slow the first time it runs for a repo**

The first time Flog runs for a repo, it runs `git commit-graph write`.
This ultimately makes it run faster.

Disable this feature:

```
let g:flog_write_commit_graph = 0
```

Set args (defaults shown):

```
let g:flog_write_commit_graph_args = '--reachable --progress'
```

**Flog gets slower over time for repos**

The commit graph will eventually become out of date.

You can update it by running:

```
git commit-graph write --reachable --progress
```

**Flog takes a long time to load for many commits**

By default, Flog will shows 5,000 commits.

Launch with less commits:

```
:Flog -max-count=2000
```

Launch with less commits by default:

```
let g:flog_permanent_default_opts = { 'max_count': 2000 }
```

**Flog takes a long time to load for complex git branch graphs**

Toggle the graph with `gx` or launch with `:Flog -no-graph`.

**Other issues**

Please [post an issue](https://github.com/rbong/vim-flog/issues/) or [discussion](https://github.com/rbong/vim-flog/discussions) if you run into any other speed problems.

## What are the differences with other branch viewers?

[gv.vim](https://github.com/junegunn/gv.vim) is an ultra-light branch viewer.

[gitv](https://github.com/gregsexton/gitv) is a fully featured branch viewer.

Flog is faster than gitv.
Flog is slower than gv.vim, but in many cases only marginally.

gv.vim and gitv rely on the output of `git log --graph`.
Flog draws the git branch graph itself.
This allows for branch highlighting and beautiful git branch graphs.

Flog is more customizable and flexible than gitv.
gv.vim does not have any customization or flexibility by design.

Flog has features which have no equivalent in either of the other branch viewers.
This includes commit marks, some navigation mappings, and contextually aware command completion.

## How can I learn how to use flog?

See `:help flog` for all commands and options.
See [examples](EXAMPLES.md) for detailed walkthroughs.
Please [start a discussion](https://github.com/rbong/vim-flog/discussions/new/choose) if you have any questions or [post an issue](https://github.com/rbong/vim-flog/issues/) if you run into any bugs.
