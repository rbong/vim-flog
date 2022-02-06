#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

source "$TEST_DIR/lib_dir.sh"
source "$TEST_DIR/lib_diff.sh"
source "$TEST_DIR/lib_git.sh"
source "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_simple)

WORKTREE=$(git_init graph_simple)
cd "$WORKTREE"

git_commit -m a
git_commit -m b
git_commit -m c
git_commit -m d

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command "exec 'Flog -format=%s' | silent w $VIM_OUT"

diff_data "$TMP/out" "graph_simple_out"
