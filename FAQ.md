# Flog FAQ

**Why not just use the `git log --graph` command?**

To interact with commits.

**Why have a branch viewer inside of vim?**

This allows seamlessly switching between navigating the commit history, running git commands, and editing files checked into git.

It also prevents having to learn another git interface on top of [fugitive](https://github.com/tpope/vim-fugitive).

If you want to know everything you can do with fugitive, I recommend [the Vimcasts fugitive series](http://vimcasts.org/blog/2011/05/the-fugitive-series/).

**What are the differences with other branch viewers?**

[gv.vim](https://github.com/junegunn/gv.vim) is an ultra-light branch viewer, whereas Flog is fully featured.
Flog allows updating the graph, running commands, and customization, where gv does not.

[gitv](https://github.com/gregsexton/gitv) is another fully featured branch viewer.
Flog is a next generation branch viewer that learns a lot of lessons from gitv.
It has a better defined argument system, more robust window management, more stable update system, has the ability to run more commands in the graph easier, has cleaner mappings, and supports any log format.

**How can I learn how to use flog?**

See `:help flog` for all commands and options.
See [the examples](EXAMPLES.md) for detailed walkthroughs of different operations using flog.
Please [post an issue](https://github.com/rbong/vim-flog/issues) if you have any questions on how to do anything.
