#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_octopus)

WORKTREE=$(git_init graph_merge_octopus)
cd "$WORKTREE"

git_commit -m a
git_tag a
git_commit -m b
git_tag b

git_checkout a
git_commit -m side-1
git_tag side-1

git_checkout a
git_commit -m side-2
git_tag side-2

git_checkout a
git_commit -m side-3
git_tag side-3

git_checkout b
git_merge -m c side-1 side-2 side-3

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command "exec 'Flog -format=%s' | silent w $VIM_OUT"

diff_data "$TMP/out" "graph_octopus_out"
