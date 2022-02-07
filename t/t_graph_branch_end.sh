#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_branch_end)

WORKTREE=$(git_init graph_branch_end)
cd "$WORKTREE"

git_commit -m branch-1-a
git_tag branch-1-a
git_commit -m branch-1-b
git_tag branch-1-b
git_commit -m branch-1-c
git_tag branch-1-c

git_checkout branch-1-a
git_commit -m branch-3-a
git_tag branch-3-a

git_checkout branch-1-a
git_commit -m branch-4-a
git_tag branch-4-a

git_checkout branch-1-c
git_merge -m branch-2-a --no-ff branch-3-a branch-4-a
git_tag branch-2-a

git_checkout branch-4-a
git_commit -m branch-4-b
git_tag branch-4-b

git_checkout branch-3-a
git_commit -m branch-3-b
git_tag branch-3-b

git_checkout branch-2-a
git_commit -m branch-2-b
git_tag branch-2-b

git_checkout branch-1-c
git_tag branch-1-d
git_merge -m branch-1-e --no-ff branch-2-b branch-3-b branch-4-b

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command "exec 'Flog -order=date -format=%s' | silent w $VIM_OUT"

diff_data "$TMP/out" "graph_branch_end_out"
