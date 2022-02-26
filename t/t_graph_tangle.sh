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

git_commit_tag 1-a 1-b 1-c 1-d 1-e

git_checkout 1-b
git_commit_tag 2-a

git_checkout 1-c
git_commit_tag 3-a

git_checkout 1-e
git_commit_tag 1-f

git_checkout 2-a
git_merge -m 2-b 1-e
git_tag 2-b

git_checkout 3-a
git_commit_tag 3-b

git_checkout 1-f
git_commit_tag 1-g

git_checkout 2-b
git_merge -m 2-c 3-a
git_tag 2-c

git_checkout 1-g
git_merge -m 1-h 3-b
git_merge -m 1-i 2-c
git_tag 1-i

git_checkout 1-i
git_commit_tag 4-a

git_checkout 1-i
git_commit_tag 3-c

git_checkout 1-i
git_commit_tag 1-j

git_checkout 1-i
git_commit_tag 2-d

git_checkout 1-j
git_merge -m 1-k 3-c 4-a
git_merge -m 1-l 2-d

VIM_OUT=$(get_relative_dir "$TMP")/out
run_vim_command <<EOF
Flog -order=date -format=%s
silent w $VIM_OUT
EOF

diff_data "$TMP/out" "graph_tangle_out"

run_vim_command <<EOF
Flog -format=%s -rev=2-c..2-d
silent w! $VIM_OUT
EOF

diff_data "$TMP/out" "graph_tangle_range_out"
