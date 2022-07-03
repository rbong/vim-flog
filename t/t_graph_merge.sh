#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_merge)

WORKTREE=$(git_init graph_merge)
cd "$WORKTREE"

git_commit_tag 1-a 1-b 1-c

git_checkout 1-b
git_commit_tag 2-a 2-b

git_checkout 1-c
git_merge -m 1-d 2-b
git_commit -m 1-e

VIM_OUT="$TMP/out"
run_vim_command <<EOF
Flog -format=%s
silent w $VIM_OUT
EOF

diff_data "$TMP/out" "graph_merge_out"
