#!/bin/sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_octopus)

WORKTREE=$(git_init graph_merge_octopus)
cd "$WORKTREE"

git_commit_tag 1-a 1-b

git_checkout 1-a
git_commit_tag 2-a

git_checkout 1-a
git_commit_tag 3-a

git_checkout 1-a
git_commit_tag 4-a

git_checkout 1-b
git_merge -m 1-c 2-a 3-a 4-a

VIM_OUT="$TMP/out"
run_vim_command <<EOF
Flog -format=%s
silent w $VIM_OUT
EOF

diff_data "$TMP/out" "graph_octopus_out"
