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
[gitgraph.nvim](https://github.com/isakbm/gitgraph.nvim) is a Neovim branch viewer with very particular branch drawing.

**Maintenance**

gv.vim is maintained.
gitv is not maintained.
gitgraph.nvim is a work in progress, so the details related to that plugin here may change.

Flog is, at the time of writing, also actively maintained.

**Branch drawing algorithm*

gv.vim and gitv rely on the output of `git log --graph`.
Flog draws the git branch graph itself.
This allows for branch highlighting and beautiful git branch graphs.

gitgraph.nvim also draws the graph itself.
Its graph drawing algorithm aims for a better graph on large repos.
It currently is much slower at the initial rendering of the graph.

**Initial load time**

Flog loads faster than gitv.
Flog sometimes loads slower than gv.vim.
Flog loads faster than gitgraph.nvim.

Comparison with gitgraph.nvim using [git/git](https://github.com/git/git):

```
# Baseline
% time nvim -c 'qa'
nvim -c 'qa'  0.25s user 0.05s system 98% cpu 0.300 total

# gitgraph.nvim
% time vim -c "lua require('gitgraph').draw({}, { all = true, max_count = 3000 })" -c qa
29.59s user 0.69s system 99% cpu 30.312 total

# Flog
% time nvim README.md -c 'Flog -all -max-count=3000' -c 'qa'
0.77s user 0.10s system 122% cpu 0.709 total
```

**Branch highlighting**

gv.vim does not have branch highlighting.
gitv has similar branch highlighting to Flog, however it may cause more lag.

gitgraph.nvim currently has more accurate branch highlighting than Flog.
Branch highlighting may also be more performant in gitgraph.nvim while scrolling in large repos and on weaker machines.

**Customization**

Flog allows you to customize your output format and other features.
Flog is more customizable and flexible than gitv.
gv.vim does not have any customization or flexibility by design.
gitgraph.nvim is also customizable.

**Editor support**

Flog supports Vim and Neovim, as do gv.vim and gitv.
gitgraph.nvim only supports Neovim.

**Git client integration**

Flog is designed as an extension to [fugitive.vim](https://github.com/tpope/vim-fugitive).
gitv also integrates with fugitive.vim.
The other plugins do not integrate with third-party git plugins by default.

**Code quality and testing strategy**

Flog's code was originally based off of gitv.vim, which is not maintained.
Since then it has seen many improvements.

gv.vim is a simple plugin with good quality code.

gitgraph.nvim is a good quality plugin.
It has not yet gone through aggressive optimization like Flog yet, and it is cleaner and more readable.

**Testing strategy**

gitv.vim and gv.vim do not have tests.

Flog focuses on integration tests.
Because of aggressive removal of function overhead for optimization, Flog has no functions to test for branch drawing.
This also allows ensuring the plugin works end-to-end.

gitgraph.nvim has unit tests.
These types of tests typically allow more easily identifying the exact spot where code is failing.

**Other features**

Flog has features which have no equivalent in the other branch viewers.
This includes commit marks, some navigation mappings, and contextually aware command completion.

## How can I learn how to use flog?

See `:help flog` for all commands and options.
See [examples](EXAMPLES.md) for detailed walkthroughs.
Please [start a discussion](https://github.com/rbong/vim-flog/discussions/new/choose) if you have any questions or [post an issue](https://github.com/rbong/vim-flog/issues/) if you run into any bugs.
