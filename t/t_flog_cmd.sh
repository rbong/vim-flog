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

# Run :Flog from empty tab
run_vim_command <<EOF
Flog
call flog#test#Assert('&filetype ==# "floggraph"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 1')

normal gq
call flog#test#Assert('&filetype !=# "floggraph"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 1')
EOF

# Run :Flog from non-empty tab
run_vim_command <<EOF
e README.md
Flog
call flog#test#Assert('&filetype ==# "floggraph"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 2')

normal gq
call flog#test#Assert('&filetype !=# "floggraph"')
call flog#test#Assert('bufname() ==# "README.md"')
call flog#test#Assert('winnr("$") == 1')
call flog#test#Assert('tabpagenr() == 1')
EOF

# Run :Flog with fake output
run_vim_command <<EOF
Flog -rev=fake

" Test that opening an empty commit does not fail
exec "normal \<CR>"

call flog#test#Assert('winnr("$") == 1')
EOF
