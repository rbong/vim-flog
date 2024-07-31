#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_merge_multiline)

WORKTREE=$(git_init graph_merge_multiline)
cd "$WORKTREE"

git_commit_tag 1-a 1-b 1-c

git_checkout 1-b
git_commit_tag 2-a 2-b

git_checkout 1-c
git_merge -m 1-d 2-b
git_commit_tag 1-e

FLOG_CMD="Flog -format=%s%n%s"

VIM_OUT="$TMP/basic_out"
run_vim_command <<EOF
$FLOG_CMD
silent w $VIM_OUT
EOF

diff_data "$VIM_OUT" "graph_merge_multiline_out"

VIM_OUT="$TMP/extended_out"
run_vim_command <<EOF
let g:flog_enable_extended_chars = 1
$FLOG_CMD
silent w $VIM_OUT
EOF

diff_data "$VIM_OUT" "graph_merge_multiline_extended_out"
