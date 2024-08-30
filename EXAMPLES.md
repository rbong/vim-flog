# Flog Examples

## Checking Out a Branch

1. Open the git branch graph with `:Flog`.
2. Make sure your commit is in the git branch graph by pressing `a` to toggle showing all commits.
3. Navigate to your branch. There are a couple ways to do this:
  - Use builtin Vim navigation like `/`, `j`, `k`, etc.
  - Use `]r`/`[r` to jump between commits with refs.
4. Checkout the branch. There are also a few ways to do this:
  - Use `cob` to checkout the first local branch name, or remote branch if it is not available.
  - Use `col` to checkout the first branch name, setting it up to be tracked locally if it is a remote branch.
  - Use `:Floggit checkout <Tab>`.
    - Use the `git` mapping to prepopulate the command line with `:Floggit`, or use `co<Space>` for `:Floggit checkout<Space>`.
    - Using `:Floggit` lets you use completion for:
      - Options for git commands.
      - Git objects.
      - Contextual Flog items, such as branch names on the current line.

## Adding Default Arguments

Put this inside of your `.vimrc` to always launch Flog with the `-no-merges` and `-max-count=2000` options:

```vim
let g:flog_default_opts = {
            \ 'max_count': 2000,
            \ 'merges': 0,
            \ }
```

You can use `:Flogsetargs` after the git branch graph has launched to override these options:

```
# Clear the max count
Flogsetargs -max-count=
# Increase the max count to 3000
Flogsetargs -max-count=3000
# Remove -no-merges
Flogsetargs -merges
# Clear out options
Flogsetargs!
```

If you don't want options to be cleared when you run `:Flogsetargs!` you can use `g:flog_permanent_default_opts`.
For example, if you want to always use the short date format:

```vim
let g:flog_permanent_default_opts = {
            \ 'date': 'short',
            \ }
```

## Diffing Commits

There are several different ways to diff commits after launching Flog:
  - Press `dd` in normal mode to diff the commit under the cursor with `HEAD`.
  - Visually select the commits and use `:Floggit -s diff <Tab>` to complete the commits at the beginning and end of the selection.
  - Press `dd` in visual mode to diff the commits at the beginning and end of the selection
  - Press `d!` to diff the commit at the cursor and the commit that was previously opened with `<CR>`.

## Extension Example: Switch Diff Order

Flog has functions that allow you to easily define your own mappings and commands.
This example shows how to switch the order of commits when diffing with `dd`.

Put this code inside of your `.vimrc`:

```vim
augroup MyFlogSettings
  autocmd FileType floggraph nno <buffer> dd :<C-U>exec flog#Format('vertical belowright Floggit -b -s -t diff HEAD %h')<CR>
  autocmd FileType floggraph vno <buffer> dd :<C-U>exec flog#Format("vertical belowright Floggit -b -s -t diff %(h'>) %(h'<)")<CR>
augroup END
```

`Floggit` runs a command using Fugitive's `Git` command.
The `-b` flag causes the focus to return to the commit graph window after runnign the command.
The `-s` flag causes the commit graph to not explicitly update after running the command.
The `-t` flag treats any windows it opens as temporary side windows.

The `flog#Format()` function uses special format specifier items, similar to `printf()`, to get contextual information from Flog.

The `%h` format specifier item used here will resolve to the hash on the current line.
`%(h'>) %(h'<)` will resolve to the hashes at the end and beginning of the visual selection.

When diffing with `dd`, Flog will now show a diff from bottom-to-top, instead of top-to-bottom.
This is because `HEAD`/`%h` have been swapped in normal mode from the default command, and `%(h'<)`/`%(h'>)` have been swapped in visual mode.

See `:help flog-command-format` for more format specifiers.
See `:help flog-functions` for more details about calling command functions.
You can also view [the floggraph filetype script](https://github.com/rbong/vim-flog/blob/master/ftplugin/floggraph.vim), which contains more examples.
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
  - This will display an inline patch, which you can trigger with `gp`.
- If you haven't already, look through `:help flog`. There is much that still hasn't been covered here.
