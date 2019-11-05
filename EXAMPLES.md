# Flog Examples

## Basic Example: Merging a Branch Into master

This example covers launching flog, navigating the graph, and running basic commands.

1. Run `:Flog` in your repository to view the commit history, also known as the graph.

If your repository has lots of commits and the command is slow to finish, you might want to instead run `:Flog -max-count=1000`

You can set this argument by default by putting `let g:flog_default_arguments = { 'max_count': 1000 }` in your `.vimrc`.

You can also use `:Flogupdate -max-count=1000` to set the argument after running `:Flog` or `:Flogupdate -max-count=` to unset it.

2. Type in `git c<Tab> master` to check out the master branch if you are not already on it - it will automatically complete to `:Floggit checkout master`.

The graph will be updated after master is checked out, which will happen on any command.
The master branch can also be completed, so if you don't have many branches you may be able to type `m<Tab>` to complete master.

3. Press the `a` key to toggle showing all commits.

You can also pass in this argument with `:Flog -all`.

4. Find the branch you want to merge using builtin vim navigation and `[r`/`]r` to jump between refs.

It can be very useful to search the current graph window with `/<pattern>`, or even to use `<C-D>` and `<C-U>` to quickly scroll through the graph.

You can also use `:Flogjump <Tab>` to look through and navigate to the currently loaded branch names and tags.

5. Type in `git m<Tab> <Tab><Tab>`. This will automatically complete to `:Floggit merge <branch>`.

If you'd like to save the merge output to a buffer, use `git!` instead of `git`.
You can run any git command using this command.

This seems like a lot, but as you get used to running commands you'll do all of this without thinking, especially with all of the completion available.

## Visual Selection Example: Diffing Two Commits

This example shows how to use visual selection mode to run commands on two different commits.

1. Launch the graph with `:Flog`.
2. Move your cursor to the first commit you want to diff and press `v`.
3. While still in visual selection mode, move your cursor to the second commit you want to diff.
4. Still in visual selection mode, type in `git diff <Tab> <Tab><Tab>`.

This will complete to `:Floggit diff <first commit> <second commit>`.

Any ref names and commit hashes at the two ends of the visual selection will be completed first when using `:Floggit` in visual selection mode.
You may have to press `<Tab>` more times if your commits have addition ref names to cycle through for command completion.

## Extension Example: Automating Diffing Two Commits

This example shows how to make a binding to automate the diffing process shown in the previous example by using flog's publicly available functions.

Put this code inside of your `.vimrc`:

```vim
function! Flogdiff()
  let first_commit = flog#get_commit_data(line("'<")).short_commit_hash
  let last_commit = flog#get_commit_data(line("'>")).short_commit_hash
  call flog#git('vertical belowright', '!', 'diff ' . first_commit . ' ' . last_commit)
endfunction

augroup flog
  autocmd FileType floggraph vno gd :<C-U>call Flogdiff()<CR>
augroup END
```

You can now diff commits by visually selecting them and pressing `gd`.

Let's break this code down.

`flog#get_commit_data` gets the commit for the given line number, in this case, beginning and end of the selection, or `line("'<")` and `line("'>")`.

In the returned commit data, we use the key `short_commit_hash` to get the commit hash.

`flog#git` is just the functional equivalent of `:Floggit`.

The first two arguments are the mods (see `:help <mods>`) and bang (see `:help <bang>`) that would be normally passed to the function.
The last argument is the git command, in this case a diff between the two commits.

`autocmd FileType floggraph` allows us to add settings just for the `:Flog` window.
We bind the function we created to the `gd` key.

The best way to learn how to use flog's internal functions is to [read them](https://github.com/rbong/vim-flog/blob/master/autoload/flog.vim) and try them out.
Try mainly looking at the structure of the return value of `flog#get_commit_data(line('.'))`.

It also helps to [learn a little vimscript](http://learnvimscriptthehardway.stevelosh.com/).
If you have any problems, we're happy to help if you [post an issue](https://github.com/rbong/vim-flog/issues).

## Additional Examples

There is a lot more you can do with flog than just what's here.
Here are some brief ideas.

* You can use what you learned from the first example to run `rebase` or `cherry-pick` instead of `merge`. Everything but the command is the same. You can also complete subcommands such as `git rebase --abort`.
* You can do git commands like `revert` and `reset` using `:Floggit` completion, not just operations between branches.
* You can start/manage a bisect with `:Floggit` commands, taking advantage of completion, and toggle seeing the current commits in the bisect with `gb`.
* You can view the history of a file next to the file itself with `:Flogsplit -path=%`.
* If you haven't already, look through `:help flog`. There are many commands that still haven't been covered here.
