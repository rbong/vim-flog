# Flog FAQ

**Why not just use the `git log --graph` command?**

The `git log --graph` command allows you to visualize branch history, but it doesn't allow you to view commit diffs interactively.
You can use the `-p` option to display commit diffs inline, but it makes the output difficult to parse through and often requires limiting commits.

Branch viewers like `vim-flog` allow visualizing the branch history, but also allow interactively viewing commit diffs, updating the graph, and launching commands.

Also, with `vim-flog`, you're still using a wrapper around `git log --graph`, meaning you can do everything with it you can do with vanilla git and more.

**Why have a branch viewer inside of vim?**

There are lots of branch viewers for git, such as the `gitk` system command, which comes with most flavors of git.

These programs can be useful, but you need to switch out of vim to use them.
That means you're losing all of the great navigation options that come with vim, and to do things you would normally do with `vim-fugitive` you have to learn a new interface.
Overall, it's more difficult when using an external viewer to seamlessly switch between navigation of the git history, running git commands, and editing files checked into git using vim.

If you want to know everything you can do with `vim-fugitive`, I recommend [this tutorial series](http://vimcasts.org/blog/2011/05/the-fugitive-series/).

**What are the differences with other branch viewers?**

[gv.vim](https://github.com/junegunn/gv.vim) is an ultra-light branch viewer just designed to view the commit graph and view commit diffs.
`vim-flog` has the fundamental difference that it is a fully featured branch viewer rather than a light one.
It allows running more commands inside the commit graph, and allows for customization, where `gv.vim` does not.

[gitv](https://github.com/gregsexton/gitv) is a branch viewer with tons of features.

`vim-flog` was created by a maintainer of gitv.
It is designed to do everything gitv can do and more, while still being lighter and more stable.
`vim-flog` owes everything to gitv, but it does things that gitv can only do with a rewrite and change of interface.

Feature-wise, `vim-flog` has a more well-defined argument system than gitv with more autocompletion.
It has a robust window management system, where gitv has a fixed window layout that is prone to break.
It allows for running any command easily inside the commit graph, where gitv has hardcoded commands with complicated keybindings.
It also supports custom log formats, even multiline formats, where gitv does not support custom log formats.
`vim-flog` also keeps all of its internal functions public and organized for easy extension.

**How can I learn how to use flog?**

See `:help flog` for all commands and options.
See [the examples](EXAMPLES.md) for detailed walkthroughs of different operations using flog.
Please [post an issue](https://github.com/rbong/vim-flog/issues) if you have any questions on how to do anything.
