#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_simple)

WORKTREE=$(git_init graph_simple)
cd "$WORKTREE"

git_commit_tag 1-a 1-b 1-c 1-d

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command <<EOF
Flog -format=%s
silent w $VIM_OUT
EOF

diff_data "$TMP/out" "graph_simple_out"
