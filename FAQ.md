# Flog FAQ

## How do I get Flog to run faster?

There are several ways to get Flog to run faster depending on what your exact issue is.

**Specifying the max count**

You may want to specify `-max-count=<count>`, or use `let g:flog_default_arguments = { 'max_count': <count> }`.

This restricts the log to displaying a certain number of commits.
This will increase the speed at which Flog can redraw the commit graph, generally reducing lag.

If you need to jump forward/backwards in history by `<count>`, use `[[`/`]]`

**Pre-calculating the commit graph**

In very large repositories, the commit graph can take a long time to sort when you use `git log --graph` or run Flog, even with max count specified.
In these cases you can pre-calculate the commit graph.

If you are running Git 2.24 or greater, it is enabled by default.
Otherwise it can be enabled via:

```
git config --global core.commitGraph true
git config --global gc.writeCommitGraph true
```

After that, navigate to your repository and run `git commit-graph write`.

This command may still take a long time to run, but once it has been generated, `git log --graph` and Flog will run much faster.
If you don't plan to view a large number of commits that aren't reachable, you can use `git commit-graph write --reachable` to speed up this process.

You may want to re-run this command regularly when there are enough new commits.

**Disabling graph mode**

If you want to skip generating a graph and use Flog just as a log viewer, you can pass `-no-graph` to Flog or use the `gx` binding to toggle the graph.
This is equivalent to `git log --no-graph`.

If this is still too slow, it might be because Flog has to wait until the command completes to write output to the buffer.
In these cases, you may want to resort to just using `git log` in the terminal.

**Flog is still too slow**

Flog, unlike other branch viewers like `gitk`, is just a wrapper around `git log`.
It just reads static output from the command after it finishes and writes it to a buffer.
By contrast, `gitk` reads raw commit data, calculates the graph structure itself commit-by-commit, and updates the display, all without hanging.

This may change in the future, so check back.

If you have any feedback about Flog's speed or any of the suggestions above, please see [this ongoing issue](https://github.com/rbong/vim-flog/issues/26).

## Why not just use the `git log --graph` command?

To interact with commits.

## Why have a branch viewer inside of Vim?

This allows seamlessly switching between navigating the commit history, running git commands, and editing files checked into git.

It also prevents having to learn another git interface on top of [fugitive](https://github.com/tpope/vim-fugitive).

If you want to know everything you can do with fugitive, I recommend [the Vimcasts fugitive series](http://vimcasts.org/blog/2011/05/the-fugitive-series/).

## What are the differences with other branch viewers?

[gv.vim](https://github.com/junegunn/gv.vim) is an ultra-light branch viewer, whereas Flog is fully featured.
Flog allows updating the graph, running commands, and customization, where gv does not.

[gitv](https://github.com/gregsexton/gitv) is another fully featured branch viewer.
Flog is a next generation branch viewer that learns a lot of lessons from gitv.
It has a better defined argument system, more robust window management, more stable update system, has the ability to run more commands in the graph easier, has cleaner mappings, and supports any log format.

## How can I learn how to use flog?

See `:help flog` for all commands and options.
See [the examples](EXAMPLES.md) for detailed walkthroughs of different operations using flog.
Please [post an issue](https://github.com/rbong/vim-flog/issues) if you have any questions on how to do anything.
