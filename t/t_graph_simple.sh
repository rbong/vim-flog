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

git_commit_tag a b c d

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command "exec 'Flog -format=%s' | silent w $VIM_OUT"

diff_data "$TMP/out" "graph_simple_out"
