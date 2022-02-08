#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_merge_cross)

WORKTREE=$(git_init graph_merge_cross)
cd "$WORKTREE"

git_commit_tag branch-1-a branch-1-b

git_checkout branch-1-a
git_commit_tag branch-3-a

git_checkout branch-1-b
git_commit_tag branch-2-a

git_checkout branch-1-b
git_commit_tag branch-1-c

git_checkout branch-2-a
git_merge -m branch-2-b branch-1-c branch-3-a
git_tag branch-2-b

git_checkout branch-3-a
git_commit_tag branch-3-b

git_checkout branch-2-b
git_commit_tag branch-2-c

git_checkout branch-1-c
git_commit_tag branch-1-d
git_merge -m branch-1-e branch-2-c branch-3-b

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command "exec 'Flog -order=date -format=%s' | silent w $VIM_OUT"

diff_data "$TMP/out" "graph_merge_cross_out"
