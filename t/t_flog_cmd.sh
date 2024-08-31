#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir flog_cmd)

WORKTREE=$(git_init flog_cmd)
cd "$WORKTREE"

git_commit_tag 1-a

run_vim_command <<EOF
" Empty tab
Flog

call flog#test#Assert('&filetype ==# "floggraph"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 1')

" Quit from empty tab
normal gq

call flog#test#Assert('&filetype !=# "floggraph"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 1')

" Non-empty tab
e README.md
Flog

call flog#test#Assert('&filetype ==# "floggraph"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 2')

" Quit from Non-empty tab
normal gq

call flog#test#Assert('&filetype !=# "floggraph"')
call flog#test#Assert('bufname() ==# "README.md"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 1')

" Empty output
Flog -rev=fake

" Test that opening an empty commit does not fail
exec "normal \<CR>"

call flog#test#Assert('winnr("$") == 1')
EOF
