#!/usr/bin/env sh

set -e

TEST_DIR=$(realpath -- "$(dirname -- "$0")")

. "$TEST_DIR/lib_dir.sh"
. "$TEST_DIR/lib_diff.sh"
. "$TEST_DIR/lib_git.sh"
. "$TEST_DIR/lib_vim.sh"

TMP=$(create_tmp_dir graph_tangle)

WORKTREE=$(git_init graph_merge_tangle)
cd "$WORKTREE"

git_commit -m a
git_commit -m b
git_tag b
git_commit -m c
git_tag c
git_commit -m d
git_commit -m e
git_tag e
git_commit -m f
git_commit -m g
git_tag g

git_checkout c
git_commit -m side-a
git_tag side-a
git_commit -m side-b
git_tag side-b

git_checkout g
git_merge -m h side-b
git_tag h

git_checkout b
git_commit -m tangle-a
git_merge -m tangle-b e
git_merge -m tangle-c side-a
git_tag tangle-c

git_checkout h
git_merge -m i tangle-c
git_tag i
git_commit -m j
git_tag j

git_checkout i
git_commit -m octopus-a
git_tag octopus-a
git_checkout i
git_commit -m octopus-b
git_tag octopus-b

git_checkout i
git_commit -m reach-a
git_tag reach-a

git_checkout j
git_merge -m k octopus-a octopus-b
git_merge -m l reach-a

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command "exec 'Flog -sort=date -format=%s' | silent w $VIM_OUT"

diff_data "$TMP/out" "graph_tangle_out"
