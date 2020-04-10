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

## Diffing Commits

There are several different ways to diff commits after launching Flog:
  - Press `dd` in normal mode to diff the commit under the cursor.
  - Visually select the commits and use `:Floggit diff <Tab>` to complete the commits at the beginning and end of the selection.
  - Press `dd` in visual mode to diff the commits at the beginning and end of the selection

## Extension Example: Automating Diffing Two Commits

This example shows how the `dd` binding is implemented.

Put this code inside of your `.vimrc`:

```vim
augroup flog
  autocmd FileType floggraph vno <buffer> D :<C-U>call flog#run_tmp_command(
    \ flog#format_commit_selection(
      \ flog#get_commit_selection(),
      \ 'vertical belowright Git diff %s %s'))<CR>
  autocmd FileType floggraph nno <buffer> D :<C-U>call flog#run_tmp_command(
    \ flog#format_commit(
      \ flog#get_commit_at_line(),
      \ 'vertical belowright Git diff HEAD %s'))<CR>
augroup END
```

You can now diff commits by visually selecting them and pressing `D`, equivalent to `dd`.

Let's break this code down.

`flog#get_commit_selection` will return the commits at the beginning and end of the virtual selection.

`flog#format_commit_selection` will format those commit based on a format specifier for `printf()`.
The commands will be formatted as `'vertical belowright Git diff <commit 1> <commit 2>'`.

`flog#run_tmp_command` tells flog to run the command and treat any windows it opens as temporary.

For normal mode, similar functions are used, only the format specifier will format the single commit as `... Git diff HEAD <commit>`.

For more details, see `:help flog-functions` and `:help flog-about`.

## Additional Examples

There is a lot more you can do with flog than just what's here.
Here are some brief ideas.

- You can use what you learned from the first example to run `rebase` or `cherry-pick` instead of `merge`.
- You can do git commands like `revert` and `reset` using `:Floggit` completion, not just operations between branches.
- There are a lot more mappings for dealing with commits than shown here. See `:help flog-mappings` for more.
- You can start/manage a bisect with `:Floggit` commands, taking advantage of completion, and toggle seeing the current commits in the bisect with `gb`.
- You can view the history of a file next to the file itself with `:Flogsplit -path=%`.
- You can view the history for a particular range of lines in a file by visually selecting it and then typing `:Flog`.
- If you haven't already, look through `:help flog`. There are many commands that still haven't been covered here.
