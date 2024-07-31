#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_octopus_left)

WORKTREE=$(git_init graph_merge_octopus_left)
cd "$WORKTREE"

git_commit_tag 1-a 1-b

git_checkout 1-a
git_commit_tag 2-a

git_checkout 1-a
git_commit_tag 3-a

git_checkout 1-a
git_commit_tag 4-a

git_checkout 1-b
git_merge -m 2-b 2-a 3-a 4-a
git_tag 2-b

git_checkout 1-b
git_commit_tag 1-c

FLOG_CMD="Flog -format=%s -rev=1-c -rev=2-b"

VIM_OUT="$TMP/basic_out"
run_vim_command <<EOF
$FLOG_CMD
silent w $VIM_OUT
EOF

diff_data "$VIM_OUT" "graph_octopus_left_out"

VIM_OUT="$TMP/extended_out"
run_vim_command <<EOF
let g:flog_enable_extended_chars = 1
$FLOG_CMD
silent w $VIM_OUT
EOF

diff_data "$VIM_OUT" "graph_octopus_left_extended_out"
