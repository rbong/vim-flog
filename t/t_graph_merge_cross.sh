#!/bin/bash

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_merge_cross)

WORKTREE=$(git_init graph_merge_cross)
cd "$WORKTREE"

git_commit_tag 1-a 1-b

git_checkout 1-a
git_commit_tag 3-a

git_checkout 1-b
git_commit_tag 1-c

sleep 1

git_checkout 1-b
git_commit_tag 2-a

git_checkout 2-a
git_merge -m 2-b 1-c 3-a
git_tag 2-b

git_checkout 3-a
git_commit_tag 3-b

git_checkout 2-b
git_commit_tag 2-c

git_checkout 1-c
git_commit_tag 1-d
git_merge -m 1-e 2-c 3-b

VIM_OUT="$TMP/out"
run_vim_command <<EOF
Flog -order=date -format=%s
silent w $VIM_OUT
EOF

diff_data "$TMP/out" "graph_merge_cross_out"
