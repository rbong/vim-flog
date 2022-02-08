#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_tangle_range)

WORKTREE=$(git_init graph_merge_tangle_range)
cd "$WORKTREE"

git_commit_tag a b c d e f g

git_checkout c
git_commit_tag side-a side-b

git_checkout g
git_merge -m h side-b
git_tag h

git_checkout b
git_commit_tag tangle-a
git_merge -m tangle-b e
git_merge -m tangle-c side-a
git_tag tangle-c

git_checkout h
git_merge -m i tangle-c
git_tag i
git_commit_tag j

git_checkout i
git_commit_tag octopus-a

git_checkout i
git_commit_tag octopus-b

git_checkout i
git_commit_tag reach-a

git_checkout j
git_merge -m k octopus-a octopus-b
git_merge -m l reach-a

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command "exec 'Flog -format=%s -rev=tangle-c..reach-a' | silent w $VIM_OUT"

diff_data "$TMP/out" "graph_tangle_range_out"
