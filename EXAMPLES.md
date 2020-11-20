# Flog Examples

## Checking Out a Branch

1. Launch the graph with `:Flog` (if this runs slowly for you, see [FAQ](FAQ.md)).
2. Make sure your commit is in the graph by pressing `a` to toggle showing all commits.
3. Navigate to your branch. There are a few ways to do this:
  - Use builtin VIM navigation like `/`, `j`, `k`, etc.
  - Use `]r`/`[r` to jump between commits with refs.
  - Use `:Flogjump` to jump towards the commit with completion.
4. Checkout the branch. There are also a few ways to do this:
  - Use `:Floggit checkout <Tab>`. This will complete the commit name.
  - Use the `git` mapping to prepopulate the command line with `:Floggit<Space>`, or use `co<Space>` for `:Floggit checkout<Space>`.
  - Use `cob` to checkout the first local branch name, or remote branch if it is not available.
  - Use `cot` to checkout the first branch name, setting it up to be tracked locally if it is a remote branch.

## Adding Default Arguments

Put this inside of your `.vimrc` to always launch Flog with the `-all` and `-max-count=2000` options:

```vim
let g:flog_default_arguments = {
            \ 'max_count': 2000,
            \ 'all': 1,
            \ }
```

You can use `:Flogsetargs` after the graph has launched to override these options:

```
# Clear the max count
Flogsetargs -max-count=
# Increase the max count to 3000
Flogsetargs -max-count=3000
# Clear out options
Flogsetargs!
```

If you don't want options to be cleared when you run `:Flogsetargs!` you can use `g:flog_permanent_default_arguments`.
For example, if you want to always use the short date format:

```vim
let g:flog_permanent_default_arguments = {
            \ 'date': 'short',
            \ }
```

## Diffing Commits

There are several different ways to diff commits after launching Flog:
  - Press `dd` in normal mode to diff the commit under the cursor.
  - Visually select the commits and use `:Floggit diff <Tab>` to complete the commits at the beginning and end of the selection.
  - Press `dd` in visual mode to diff the commits at the beginning and end of the selection

## Extension Example: Switch Diff Order

Instead of trying to provide settings for everything, Flog provides utility functions for customization.
This example shows how to switch the order of commits when diffing with `dd`.

Put this code inside of your `.vimrc`:

```vim
augroup flog
  autocmd FileType floggraph nno <buffer> dd :<C-U>call flog#run_tmp_command('vertical belowright Git diff HEAD %h')<CR>
  autocmd FileType floggraph vno <buffer> dd :<C-U>call flog#run_tmp_command("vertical belowright Git diff %(h'>) %(h'<)")<CR>
augroup END
```

`flog#run_tmp_command` tells flog to run the command and treat any windows it opens as temporary.
You can also use `flog#run_command`, which runs a command using the same syntax without temporary windows.

This function can use different special format specifiers, similar to `printf()`.
In this case, `%h` will resolve to the hash on the current line, and `%(h'>) %(h'<)` will resolve to the hashes at the end and beginning of the visual selection.

When diffing with `dd`, Flog will now show a diff from bottom-to-top, instead of top-to-bottom.
This is because `%(h'<)` and `%(h'>)` have been swapped from the default command.

See `:help flog-command-format` for more format specifiers.
See `:help flog-functions` for more details about calling command functions.
You can also view [the floggraph filetype script](https://github.com/rbong/vim-flog/blob/master/ftplugin/floggraph.vim), which effectively serves as further examples of Flog's utility functions.
Finally, if you would like to view user-created commands, check out the [Wiki](https://github.com/rbong/vim-flog/wiki/Custom-Commands).

## Additional Examples

There is a lot more you can do with flog than just what's here.
Here are some brief ideas.

- You can use what you learned from the first example to run `rebase` or `cherry-pick` instead of `merge`.
- You can do git commands like `revert` and `reset` using `:Floggit` completion, not just operations between branches.
- There are a lot more mappings for dealing with commits than shown here. See `:help flog-mappings` for more.
- You can start/manage a bisect with `:Floggit` commands, taking advantage of completion, and toggle seeing the current commits in the bisect with `gb`.
- You can view the history of a file next to the file itself with `:Flogsplit -path=%`.
- You can view the history for a particular range of lines in a file by visually selecting it and then typing `:Flog`.
  This will display an inline patch, which you can trigger with `gp`.
- If you haven't already, look through `:help flog`. There are many commands that still haven't been covered here.
